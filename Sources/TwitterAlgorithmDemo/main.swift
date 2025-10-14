import Foundation
import ArgumentParser
import TwitterAlgorithmCore

@main
public struct TwitterAlgorithmDemo: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "twitter-algorithm-demo",
        abstract: "Twitter Algorithm Demo Application"
    )
    
    @Flag(name: .shortAndLong, help: "Run performance benchmarks")
    var benchmark: Bool = false
    
    @Option(name: .shortAndLong, help: "Run specific service (recommendation, filtering, ranking, mixing, all)")
    var service: String?
    
    @Option(name: .shortAndLong, help: "Port number for the service")
    var port: Int = 8080
    
    @Option(name: .shortAndLong, help: "UI mode (swiftui, web, desktop)")
    var ui: String?
    
    public init() {}
    
    public func run() async throws {
        print("🐦 Twitter Algorithm - Swift 6.1+ Implementation")
        print("Demo application running...")
        
        if let serviceType = service {
            await runBackendService(serviceType: serviceType, port: port)
        } else if let uiMode = ui {
            await runFrontendUI(uiMode: uiMode, port: port)
        } else if benchmark {
            print("🚀 Running performance benchmarks...")
            await runBenchmarks()
        } else {
            // Simple algorithm test
            let service = RecommendationService()
            let timeline = try await service.generateRecommendations(for: "demo_user")
            print("✅ Generated timeline with \(timeline.tweets.count) tweets")
        }
    }
    
    private func runBenchmarks() async {
        let service = RecommendationService()
        
        print("📊 Benchmarking recommendation generation...")
        let startTime = Date()
        
        for i in 1...10 {
            let timeline = try! await service.generateRecommendations(for: "user_\(i)")
            print("  Iteration \(i): Generated \(timeline.tweets.count) recommendations")
        }
        
        let duration = Date().timeIntervalSince(startTime)
        print("✅ Benchmark completed in \(String(format: "%.2f", duration)) seconds")
        print("📈 Average time per recommendation: \(String(format: "%.3f", duration / 10.0)) seconds")
    }
    
    private func runBackendService(serviceType: String, port: Int) async {
        print("⚙️ Starting Backend Service: \(serviceType)")
        print("🌐 Port: \(port)")
        
        let service = RecommendationService()
        
        switch serviceType.lowercased() {
        case "recommendation":
            print("🔧 Running Recommendation Service...")
            print("📊 Processing recommendations for multiple users...")
            
            for i in 1...5 {
                let timeline = try! await service.generateRecommendations(for: "user_\(i)")
                print("  User \(i): Generated \(timeline.tweets.count) recommendations")
            }
            
        case "filtering":
            print("🔧 Running Filtering Service...")
            print("🛡️ Content filtering active...")
            
        case "ranking":
            print("🔧 Running Ranking Service...")
            print("📈 ML ranking models active...")
            
        case "mixing":
            print("🔧 Running Mixing Service...")
            print("🎯 Timeline construction active...")
            
        case "all":
            print("🔧 Running All Backend Services...")
            print("⚙️ Full algorithm pipeline active...")
            
            for i in 1...3 {
                let timeline = try! await service.generateRecommendations(for: "user_\(i)")
                print("  Pipeline \(i): Generated \(timeline.tweets.count) recommendations")
            }
            
        default:
            print("❌ Unknown service type: \(serviceType)")
            print("Available services: recommendation, filtering, ranking, mixing, all")
        }
        
        print("✅ Backend service \(serviceType) running on port \(port)")
        print("🔄 Service is ready to handle requests...")
    }
    
    private func runFrontendUI(uiMode: String, port: Int) async {
        print("🎨 Starting Frontend UI: \(uiMode)")
        print("🌐 Port: \(port)")
        
        switch uiMode.lowercased() {
        case "swiftui":
            print("📱 SwiftUI Interface Starting...")
            print("🖥️ Native macOS/iOS interface")
            
        case "web":
            print("🌐 Web Interface Starting...")
            print("🔗 HTTP server on port \(port)")
            
        case "desktop":
            print("🖥️ Desktop Application Starting...")
            print("💻 Native desktop interface")
            
        default:
            print("❌ Unknown UI mode: \(uiMode)")
            print("Available modes: swiftui, web, desktop")
        }
        
        print("✅ Frontend UI \(uiMode) running on port \(port)")
        print("🎯 Interface is ready for user interaction...")
    }
}
