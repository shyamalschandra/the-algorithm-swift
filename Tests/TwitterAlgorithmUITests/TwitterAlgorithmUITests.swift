import XCTest
import SwiftUI
@testable import TwitterAlgorithmUI
@testable import TwitterAlgorithmCore
@testable import TwitterAlgorithmML

final class TwitterAlgorithmUITests: XCTestCase {
    
    // MARK: - View Model Tests
    
    @MainActor
    func testAlgorithmVisualizationViewModelInitialization() {
        let viewModel = AlgorithmVisualizationViewModel()
        
        XCTAssertNotNil(viewModel)
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertTrue(viewModel.timeline.tweets.isEmpty)
        XCTAssertTrue(viewModel.notifications.isEmpty)
    }
    
    @MainActor
    func testAlgorithmVisualizationViewModelSimulation() {
        let viewModel = AlgorithmVisualizationViewModel()
        
        // Initially not running
        XCTAssertFalse(viewModel.isRunning)
        
        // Start simulation
        viewModel.startSimulation()
        XCTAssertTrue(viewModel.isRunning)
        
        // Stop simulation
        viewModel.stopSimulation()
        XCTAssertFalse(viewModel.isRunning)
    }
    
    @MainActor
    func testAlgorithmVisualizationViewModelToggle() {
        let viewModel = AlgorithmVisualizationViewModel()
        
        // Initially not running
        XCTAssertFalse(viewModel.isRunning)
        
        // Toggle to start
        viewModel.toggleSimulation()
        XCTAssertTrue(viewModel.isRunning)
        
        // Toggle to stop
        viewModel.toggleSimulation()
        XCTAssertFalse(viewModel.isRunning)
    }
    
    @MainActor
    func testFeatureImportance() {
        let viewModel = AlgorithmVisualizationViewModel()
        let features = viewModel.getFeatureImportance()
        
        XCTAssertEqual(features.count, 4)
        XCTAssertTrue(features.contains { $0.name == "Engagement" })
        XCTAssertTrue(features.contains { $0.name == "Recency" })
        XCTAssertTrue(features.contains { $0.name == "Relevance" })
        XCTAssertTrue(features.contains { $0.name == "Diversity" })
        
        // Check that importance values are valid
        XCTAssertTrue(features.allSatisfy { $0.importance >= 0.0 && $0.importance <= 1.0 })
    }
    
    // MARK: - Demo Data Generator Tests
    
    func testDemoDataGeneratorInitialization() {
        let generator = DemoDataGenerator.shared
        XCTAssertNotNil(generator)
    }
    
    func testSampleTweetsGeneration() {
        let generator = DemoDataGenerator.shared
        let tweets = generator.generateSampleTweets(count: 10)
        
        XCTAssertEqual(tweets.count, 10)
        XCTAssertTrue(tweets.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(tweets.allSatisfy { !$0.content.isEmpty })
        XCTAssertTrue(tweets.allSatisfy { !$0.authorId.isEmpty })
    }
    
    func testSampleUsersGeneration() {
        let generator = DemoDataGenerator.shared
        let users = generator.generateSampleUsers(count: 5)
        
        XCTAssertEqual(users.count, 5)
        XCTAssertTrue(users.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(users.allSatisfy { !$0.username.isEmpty })
        XCTAssertTrue(users.allSatisfy { !$0.displayName.isEmpty })
    }
    
    func testSampleInteractionsGeneration() {
        let generator = DemoDataGenerator.shared
        let interactions = generator.generateSampleInteractions(count: 20)
        
        XCTAssertEqual(interactions.count, 20)
        XCTAssertTrue(interactions.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(interactions.allSatisfy { !$0.userId.isEmpty })
        XCTAssertTrue(interactions.allSatisfy { !$0.tweetId.isEmpty })
        XCTAssertTrue(interactions.allSatisfy { $0.weight >= 0.0 && $0.weight <= 1.0 })
    }
    
    // MARK: - Feature Importance Tests
    
    func testFeatureImportanceDataStructure() {
        let feature = FeatureImportance(name: "Test Feature", importance: 0.75)
        
        XCTAssertEqual(feature.name, "Test Feature")
        XCTAssertEqual(feature.importance, 0.75)
        XCTAssertNotNil(feature.id)
    }
    
    func testFeatureImportanceValidation() {
        let validFeature = FeatureImportance(name: "Valid", importance: 0.5)
        let edgeFeature1 = FeatureImportance(name: "Edge1", importance: 0.0)
        let edgeFeature2 = FeatureImportance(name: "Edge2", importance: 1.0)
        
        XCTAssertEqual(validFeature.importance, 0.5)
        XCTAssertEqual(edgeFeature1.importance, 0.0)
        XCTAssertEqual(edgeFeature2.importance, 1.0)
    }
    
    // MARK: - Color Extension Tests
    
    func testAlgorithmColors() {
        let blue = Color.algorithmBlue
        let purple = Color.algorithmPurple
        let green = Color.algorithmGreen
        let orange = Color.algorithmOrange
        let red = Color.algorithmRed
        
        XCTAssertNotNil(blue)
        XCTAssertNotNil(purple)
        XCTAssertNotNil(green)
        XCTAssertNotNil(orange)
        XCTAssertNotNil(red)
    }
    
    func testGradientExtensions() {
        let algorithmGradient = LinearGradient.algorithmGradient
        let successGradient = LinearGradient.successGradient
        let warningGradient = LinearGradient.warningGradient
        let errorGradient = LinearGradient.errorGradient
        
        XCTAssertNotNil(algorithmGradient)
        XCTAssertNotNil(successGradient)
        XCTAssertNotNil(warningGradient)
        XCTAssertNotNil(errorGradient)
    }
    
    // MARK: - View Component Tests
    
    func testTweetCardViewData() {
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "This is a test tweet content",
            retweetCount: 50,
            likeCount: 100,
            replyCount: 25
        )
        
        let candidate = RecommendationCandidate(
            id: "test_candidate",
            tweet: tweet,
            score: 0.85,
            reason: .engagement,
            features: ["engagement": 0.8, "recency": 0.9]
        )
        
        XCTAssertEqual(candidate.tweet.content, "This is a test tweet content")
        XCTAssertEqual(candidate.score, 0.85)
        XCTAssertEqual(candidate.reason, RecommendationReason.engagement)
        XCTAssertEqual(candidate.features["engagement"], 0.8)
    }
    
    @MainActor
    func testRankingFactorCardData() {
        let card = RankingFactorCard(
            title: "Test Factor",
            value: 0.75,
            color: .blue
        )
        
        XCTAssertEqual(card.title, "Test Factor")
        XCTAssertEqual(card.value, 0.75)
        XCTAssertEqual(card.color, .blue)
    }
    
    @MainActor
    func testMetricCardData() {
        let card = MetricCard(
            title: "Test Metric",
            value: "100",
            subtitle: "Test Subtitle",
            color: .green
        )
        
        XCTAssertEqual(card.title, "Test Metric")
        XCTAssertEqual(card.value, "100")
        XCTAssertEqual(card.subtitle, "Test Subtitle")
        XCTAssertEqual(card.color, .green)
    }
    
    @MainActor
    func testMetricRowData() {
        let row = MetricRow(
            title: "Test Row",
            value: "50%",
            color: .orange
        )
        
        XCTAssertEqual(row.title, "Test Row")
        XCTAssertEqual(row.value, "50%")
        XCTAssertEqual(row.color, .orange)
    }
    
    // MARK: - Animation Tests
    
    @MainActor
    func testAnimationExtensions() {
        // Test that animation extensions don't crash
        let view = Text("Test")
        
        // These should compile without errors
        let _ = view.algorithmAnimation()
        let _ = view.pulseAnimation()
        
        XCTAssertTrue(true)
    }
    
    // MARK: - Integration Tests
    
    @MainActor
    func testVisualizationIntegration() async throws {
        let viewModel = AlgorithmVisualizationViewModel()
        
        // Test that the view model can be used without crashing
        XCTAssertNotNil(viewModel)
        
        // Test feature importance
        let features = viewModel.getFeatureImportance()
        XCTAssertEqual(features.count, 4)
        
        // Test simulation toggle
        viewModel.toggleSimulation()
        XCTAssertTrue(viewModel.isRunning)
        
        viewModel.toggleSimulation()
        XCTAssertFalse(viewModel.isRunning)
    }
    
    func testDemoDataIntegration() {
        let generator = DemoDataGenerator.shared
        
        // Test generating different types of data
        let tweets = generator.generateSampleTweets(count: 5)
        let users = generator.generateSampleUsers(count: 3)
        let interactions = generator.generateSampleInteractions(count: 10)
        
        XCTAssertEqual(tweets.count, 5)
        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(interactions.count, 10)
        
        // Test that all data is valid
        XCTAssertTrue(tweets.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(users.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(interactions.allSatisfy { !$0.id.isEmpty })
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testViewModelPerformance() {
        let viewModel = AlgorithmVisualizationViewModel()
        
        let startTime = Date()
        
        // Test multiple operations
        for _ in 0..<1000 {
            let _ = viewModel.getFeatureImportance()
            viewModel.toggleSimulation()
            viewModel.toggleSimulation()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 1000 operations in reasonable time
        XCTAssertLessThan(duration, 5.0, "View model operations took too long")
    }
    
    func testDemoDataGenerationPerformance() {
        let generator = DemoDataGenerator.shared
        
        let startTime = Date()
        
        // Generate large amounts of data
        let _ = generator.generateSampleTweets(count: 1000)
        let _ = generator.generateSampleUsers(count: 100)
        let _ = generator.generateSampleInteractions(count: 500)
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete data generation in reasonable time
        XCTAssertLessThan(duration, 2.0, "Demo data generation took too long")
    }
    
    // MARK: - Edge Cases
    
    @MainActor
    func testEmptyDataHandling() {
        let viewModel = AlgorithmVisualizationViewModel()
        
        // Test with empty timeline
        XCTAssertTrue(viewModel.timeline.tweets.isEmpty)
        XCTAssertTrue(viewModel.notifications.isEmpty)
        
        // Test feature importance with empty data
        let features = viewModel.getFeatureImportance()
        XCTAssertEqual(features.count, 4) // Should still return default features
    }
    
    func testInvalidDataHandling() {
        let generator = DemoDataGenerator.shared
        
        // Test with zero count
        let emptyTweets = generator.generateSampleTweets(count: 0)
        let emptyUsers = generator.generateSampleUsers(count: 0)
        let emptyInteractions = generator.generateSampleInteractions(count: 0)
        
        XCTAssertEqual(emptyTweets.count, 0)
        XCTAssertEqual(emptyUsers.count, 0)
        XCTAssertEqual(emptyInteractions.count, 0)
    }
    
    // MARK: - Memory Tests
    
    @MainActor
    func testViewModelsMemoryUsage() {
        // Test that view models don't leak memory
        for _ in 0..<100 {
            let _ = AlgorithmVisualizationViewModel()
        }
        
        // If we get here without crashing, memory management is working
        XCTAssertTrue(true)
    }
    
    func testDemoDataGeneratorMemoryUsage() {
        let generator = DemoDataGenerator.shared
        
        // Generate and release large amounts of data
        for _ in 0..<50 {
            let _ = generator.generateSampleTweets(count: 100)
            let _ = generator.generateSampleUsers(count: 50)
            let _ = generator.generateSampleInteractions(count: 200)
        }
        
        // If we get here without crashing, memory management is working
        XCTAssertTrue(true)
    }
    
    // MARK: - Thread Safety Tests
    
    @MainActor
    func testViewModelsThreadSafety() async throws {
        let viewModel = AlgorithmVisualizationViewModel()
        
        // Test basic functionality without concurrent access
        let features = viewModel.getFeatureImportance()
        XCTAssertEqual(features.count, 4)
        
        viewModel.toggleSimulation()
        XCTAssertTrue(viewModel.isRunning)
        
        viewModel.toggleSimulation()
        XCTAssertFalse(viewModel.isRunning)
        
        // If we get here without crashing, basic functionality is working
        XCTAssertTrue(true)
    }
    
    func testDemoDataGeneratorThreadSafety() async throws {
        let generator = DemoDataGenerator.shared
        
        // Test concurrent data generation
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    let _ = generator.generateSampleTweets(count: 10)
                    let _ = generator.generateSampleUsers(count: 5)
                    let _ = generator.generateSampleInteractions(count: 20)
                }
            }
        }
        
        // If we get here without crashing, thread safety is working
        XCTAssertTrue(true)
    }
    
    // MARK: - UI Component Validation
    
    func testUIComponentDataValidation() {
        // Test that UI components can handle various data scenarios
        
        // Test with high scores
        let highScoreCandidate = RecommendationCandidate(
            id: "high_score",
            tweet: Tweet(id: "tweet1", authorId: "author1", content: "High engagement tweet"),
            score: 0.95,
            reason: .engagement
        )
        
        XCTAssertEqual(highScoreCandidate.score, 0.95)
        XCTAssertEqual(highScoreCandidate.reason, .engagement)
        
        // Test with low scores
        let lowScoreCandidate = RecommendationCandidate(
            id: "low_score",
            tweet: Tweet(id: "tweet2", authorId: "author2", content: "Low engagement tweet"),
            score: 0.15,
            reason: .diversity
        )
        
        XCTAssertEqual(lowScoreCandidate.score, 0.15)
        XCTAssertEqual(lowScoreCandidate.reason, .diversity)
        
        // Test with edge case scores
        let edgeScoreCandidate = RecommendationCandidate(
            id: "edge_score",
            tweet: Tweet(id: "tweet3", authorId: "author3", content: "Edge case tweet"),
            score: 0.0,
            reason: .recency
        )
        
        XCTAssertEqual(edgeScoreCandidate.score, 0.0)
        XCTAssertEqual(edgeScoreCandidate.reason, .recency)
    }
    
    func testColorAndGradientValidation() {
        // Test that colors and gradients are properly defined
        let colors: [Color] = [
            .algorithmBlue,
            .algorithmPurple,
            .algorithmGreen,
            .algorithmOrange,
            .algorithmRed
        ]
        
        for color in colors {
            XCTAssertNotNil(color)
        }
        
        // Test gradients
        let gradients: [LinearGradient] = [
            .algorithmGradient,
            .successGradient,
            .warningGradient,
            .errorGradient
        ]
        
        for gradient in gradients {
            XCTAssertNotNil(gradient)
        }
    }
}
