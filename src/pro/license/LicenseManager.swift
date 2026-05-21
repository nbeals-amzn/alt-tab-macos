import Foundation

class LicenseManager {
    static let keychainService = "\(App.bundleIdentifier).license"
    static let defaultsSuiteName = "\(App.bundleIdentifier).license"

    static let shared: LicenseManager = {
        let keychain = SystemKeychain(service: keychainService)
        return LicenseManager(
            clock: SystemClock(),
            keychain: keychain,
            api: RemoteLicenseClient(baseUrl: Endpoints.licenseApiBaseUrl, keychain: keychain),
            defaults: UserDefaults(suiteName: defaultsSuiteName)!
        )
    }()

    static let trialDuration = 14
    static let keychainKeyAccount = "licenseKey"
    static let keychainInstanceAccount = "instanceId"
    static let keychainVariantAccount = "variantId"
    static let customerEmailKey = "customerEmail"
    static let lifetimeVariants: Set<String> = ["pro_lifetime"]
    static let versionLimitedVariants: [String: String] = [:]

    let clock: Clock
    let keychain: Keychain
    let api: LicenseAPI
    let defaults: UserDefaults

    var onStateChanged: ((LicenseState) -> Void)?
    var currentAppVersion: () -> String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }
    var onBeforeProUnlock: () -> Void = {}

    private(set) var state: LicenseState = .pro {
        didSet { onStateChanged?(state) }
    }

    var customerEmail: String? { "pro@user.local" }
    var isLifetimeVariant: Bool { true }
    var isProAvailable: Bool { true }
    var isProLocked: Bool { false }

    var trialStartDate: Date? { nil }
    var daysSinceTrialStart: Int { 0 }

    init(clock: Clock, keychain: Keychain, api: LicenseAPI, defaults: UserDefaults) {
        self.clock = clock
        self.keychain = keychain
        self.api = api
        self.defaults = defaults
    }

    func initialize() {
        state = .pro
    }

    func refreshState() {}

    func activate(_ licenseKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func deactivate(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func deactivateInstance(licenseKey: String, instanceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func computeState() -> LicenseState { .pro }

    func scheduleAsyncRevalidationIfNeeded() {}
    func revalidateWithServer() {}

    #if DEBUG
    func mockTrialUser() { state = .pro }
    func mockTrialExpired() { state = .pro }
    func mockTrialDay(_ day: Int) { state = .pro }
    func mockProUser() { state = .pro }
    #endif
}
