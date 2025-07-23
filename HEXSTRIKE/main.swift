import UIKit

// دومينات تيكتوك
let tiktokDomains: Set<String> = [
    "tiktok.com",
    "musical.ly",
    "tiktokcdn.com",
    "tiktokv.com",
    "tikcdn.com"
]

// Model البروكسي
class Proxy {
    let address: String
    var status: String = "لم يتم الاختبار"
    
    init(address: String) {
        self.address = address
    }
}

// متغيرات البروكسي الفعّال
var activeProxyHost: String?
var activeProxyPort: Int?

// بروتوكول فلترة الطلبات مع توجيه بروكسي تيكتوك
class ProxyFilteringURLProtocol: URLProtocol, URLSessionDataDelegate {
    var session: URLSession?
    var dataTask: URLSessionDataTask?
    
    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: "ProxyHandled", in: request) != nil {
            return false
        }
        guard let host = request.url?.host?.lowercased() else { return false }
        for domain in tiktokDomains {
            if host.contains(domain) {
                if activeProxyHost != nil {
                    return true
                }
            }
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let request = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "InvalidRequest", code: 0, userInfo: nil))
            return
        }
        URLProtocol.setProperty(true, forKey: "ProxyHandled", in: request)
        
        let config = URLSessionConfiguration.default
        if let proxyHost = activeProxyHost, let proxyPort = activeProxyPort {
            config.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable as String: true,
                kCFNetworkProxiesHTTPProxy as String(proxyHost),
                kCFNetworkProxiesHTTPPort as String(proxyPort),
                kCFStreamPropertyHTTPSProxyHost as String(proxyHost),
                kCFStreamPropertyHTTPSProxyPort as String(proxyPort)
            ]
        }
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: request as URLRequest)
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
        session = nil
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            client?.urlProtocol(self, didFailWithError: err)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
}

// التطبيق الرئيسي مع UI و Retry loop ذكي
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let proxies = [
        Proxy(address: "51.158.68.26:8811"),
        Proxy(address: "103.216.82.146:8080"),
        Proxy(address: "165.22.254.30:8080"),
        Proxy(address: "134.209.29.120:3128"),
        Proxy(address: "185.199.229.156:8080")
    ]
    
    var tableView: UITableView!
    var testButton: UIButton!
    
    // Retry settings
    let maxRetries = 3
    let retryInterval: TimeInterval = 5 // ثواني بين المحاولات
    
    // الحالة الحالية للمحاولات
    var currentRetry = 0
    var currentIndex = 0
    
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [ProxyFilteringURLProtocol.self]
        return URLSession(configuration: config)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "اختبار البروكسيات"
        view.backgroundColor = .white
        
        tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        testButton = UIButton(type: .system)
        testButton.setTitle("ابدأ الاختبار", for: .normal)
        testButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        testButton.addTarget(self, action: #selector(startTesting), for: .touchUpInside)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testButton)
        
        NSLayoutConstraint.activate([
            testButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: testButton.topAnchor, constant: -20)
        ])
    }
    
    @objc func startTesting() {
        testButton.isEnabled = false
        currentRetry = 0
        currentIndex = 0
        resetProxiesStatus()
        activeProxyHost = nil
        activeProxyPort = nil
        testProxiesSequentially()
    }
    
    func resetProxiesStatus() {
        for proxy in proxies {
            proxy.status = "لم يتم الاختبار"
        }
        tableView.reloadData()
    }
    
    func testProxiesSequentially() {
        if currentIndex >= proxies.count {
            // جربنا كل البروكسيات في هالمحاولة
            currentRetry += 1
            if currentRetry >= maxRetries {
                // انتهت كل المحاولات
                print("🚫 كل البروكسيات فشلت بعد \(maxRetries) محاولات.")
                testButton.isEnabled = true
                updateAllProxyStatus(failed: true)
                return
            } else {
                print("♻️ المحاولة رقم \(currentRetry) بعد فشل كل البروكسيات، نعيد المحاولة بعد \(retryInterval) ثانية...")
                // نرجع نجرب من أول بروكسي بعد delay
                DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
                    guard let self = self else { return }
                    self.currentIndex = 0
                    self.resetProxiesStatus()
                    self.testProxiesSequentially()
                }
                return
            }
        }
        
        let proxy = proxies[currentIndex]
        proxy.status = "جارٍ الاختبار..."
        tableView.reloadRows(at: [IndexPath(row: currentIndex, section: 0)], with: .automatic)
        
        let parts = proxy.address.split(separator: ":")
        guard parts.count == 2,
              let host = parts.first,
              let portString = parts.last,
              let port = Int(portString) else {
            proxy.status = "❌ عنوان غير صالح"
            tableView.reloadRows(at: [IndexPath(row: currentIndex, section: 0)], with: .automatic)
            currentIndex += 1
            testProxiesSequentially()
            return
        }
        
        // إعداد الجلسة مع البروكسي الحالي
        let config = URLSessionConfiguration.default
        config.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable as String: true,
            kCFNetworkProxiesHTTPProxy as String(host),
            kCFNetworkProxiesHTTPPort as String(port),
            kCFStreamPropertyHTTPSProxyHost as String(host),
            kCFStreamPropertyHTTPSProxyPort as String(port)
        ]
        
        let sessionTest = URLSession(configuration: config)
        guard let url = URL(string: "https://www.google.com") else {
            proxy.status = "❌ URL غير صالح"
            tableView.reloadRows(at: [IndexPath(row: currentIndex, section: 0)], with: .automatic)
            currentIndex += 1
            testProxiesSequentially()
            return
        }
        
        let task = sessionTest.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let _ = data, error == nil {
                    proxy.status = "✅ شغال"
                    activeProxyHost = String(host)
                    activeProxyPort = port
                    self.tableView.reloadRows(at: [IndexPath(row: self.currentIndex, section: 0)], with: .automatic)
                    print("استخدم البروكسي: \(proxy.address)")
                    self.testButton.isEnabled = true
                } else {
                    proxy.status = "❌ فشل"
                    self.tableView.reloadRows(at: [IndexPath(row: self.currentIndex, section: 0)], with: .automatic)
                    self.currentIndex += 1
                    self.testProxiesSequentially()
                }
            }
        }
        
        task.resume()
    }
    
    func updateAllProxyStatus(failed: Bool) {
        for proxy in proxies {
            if proxy.status == "جارٍ الاختبار..." {
                proxy.status = failed ? "❌ فشل" : "✅ شغال"
            }
        }
        tableView.reloadData()
    }
    
    // UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proxies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "ProxyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let proxy = proxies[indexPath.row]
        cell.textLabel?.text = proxy.address
        cell.detailTextLabel?.text = proxy.status
        return cell
    }
}
