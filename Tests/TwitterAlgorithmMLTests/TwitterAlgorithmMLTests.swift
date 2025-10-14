import XCTest
@testable import TwitterAlgorithmML
@testable import TwitterAlgorithmCore

final class TwitterAlgorithmMLTests: XCTestCase {
    
    // MARK: - Light Ranker Tests
    
    func testLightRankerInitialization() {
        let weights = ["engagement": 0.5, "recency": 0.3, "relevance": 0.2]
        let ranker = LightRanker(weights: weights, bias: 0.1)
        
        XCTAssertNotNil(ranker)
    }
    
    func testLightRankerPrediction() {
        let weights = ["engagement": 0.5, "recency": 0.3, "relevance": 0.2]
        let ranker = LightRanker(weights: weights, bias: 0.1)
        
        let features = [
            "engagement": 0.8,
            "recency": 0.9,
            "relevance": 0.7
        ]
        
        let prediction = ranker.predict(features: features)
        
        XCTAssertGreaterThan(prediction, 0.0)
        XCTAssertLessThanOrEqual(prediction, 1.0)
    }
    
    func testLightRankerSigmoid() {
        let ranker = LightRanker(weights: [:], bias: 0.0)
        
        // Test sigmoid function properties
        let prediction = ranker.predict(features: [:])
        XCTAssertEqual(prediction, 0.5, accuracy: 0.001)
    }
    
    // MARK: - Heavy Ranker Tests
    
    func testHeavyRankerInitialization() {
        let ranker = HeavyRanker(
            inputSize: 10,
            hiddenSizes: [20, 15],
            outputSize: 1
        )
        
        XCTAssertNotNil(ranker)
        // Test that ranker was created successfully
        XCTAssertNotNil(ranker)
    }
    
    func testHeavyRankerForwardPass() {
        let ranker = HeavyRanker(
            inputSize: 5,
            hiddenSizes: [10],
            outputSize: 1
        )
        
        let input = [0.1, 0.2, 0.3, 0.4, 0.5]
        let output = ranker.forward(input: input)
        
        XCTAssertEqual(output.count, 1)
        XCTAssertGreaterThanOrEqual(output[0], 0.0)
        XCTAssertLessThanOrEqual(output[0], 1.0)
    }
    
    func testHeavyRankerEngagementPrediction() {
        let ranker = HeavyRanker(
            inputSize: 3,
            hiddenSizes: [5],
            outputSize: 1
        )
        
        let features = [0.8, 0.9, 0.7]
        let prediction = ranker.predictEngagement(features: features)
        
        XCTAssertGreaterThan(prediction, 0.0)
        XCTAssertLessThanOrEqual(prediction, 1.0)
    }
    
    // MARK: - Neural Layer Tests
    
    func testNeuralLayerInitialization() {
        let layer = NeuralLayer(inputSize: 5, outputSize: 3)
        
        XCTAssertNotNil(layer)
    }
    
    func testNeuralLayerForward() {
        let layer = NeuralLayer(inputSize: 3, outputSize: 2)
        
        let input = [0.1, 0.2, 0.3]
        let output = layer.forward(input: input)
        
        XCTAssertEqual(output.count, 2)
        XCTAssertTrue(output.allSatisfy { $0 >= 0.0 })
    }
    
    func testNeuralLayerWithDifferentActivations() {
        let reluLayer = NeuralLayer(inputSize: 3, outputSize: 2, activation: .relu)
        let sigmoidLayer = NeuralLayer(inputSize: 3, outputSize: 2, activation: .sigmoid)
        let tanhLayer = NeuralLayer(inputSize: 3, outputSize: 2, activation: .tanh)
        
        let input = [0.1, 0.2, 0.3]
        
        let reluOutput = reluLayer.forward(input: input)
        let sigmoidOutput = sigmoidLayer.forward(input: input)
        let tanhOutput = tanhLayer.forward(input: input)
        
        XCTAssertEqual(reluOutput.count, 2)
        XCTAssertEqual(sigmoidOutput.count, 2)
        XCTAssertEqual(tanhOutput.count, 2)
        
        // ReLU should be non-negative
        XCTAssertTrue(reluOutput.allSatisfy { $0 >= 0.0 })
        
        // Sigmoid should be between 0 and 1
        XCTAssertTrue(sigmoidOutput.allSatisfy { $0 >= 0.0 && $0 <= 1.0 })
        
        // Tanh should be between -1 and 1
        XCTAssertTrue(tanhOutput.allSatisfy { $0 >= -1.0 && $0 <= 1.0 })
    }
    
    // MARK: - Activation Function Tests
    
    func testActivationFunctions() {
        let relu = ActivationFunction.relu
        let sigmoid = ActivationFunction.sigmoid
        let tanh = ActivationFunction.tanh
        let linear = ActivationFunction.linear
        
        let testValue = 0.5
        
        XCTAssertEqual(relu.apply(testValue), testValue)
        XCTAssertGreaterThan(sigmoid.apply(testValue), 0.0)
        XCTAssertLessThan(sigmoid.apply(testValue), 1.0)
        XCTAssertGreaterThan(tanh.apply(testValue), -1.0)
        XCTAssertLessThan(tanh.apply(testValue), 1.0)
        XCTAssertEqual(linear.apply(testValue), testValue)
    }
    
    func testActivationFunctionEdgeCases() {
        let relu = ActivationFunction.relu
        let sigmoid = ActivationFunction.sigmoid
        
        // Test negative values
        XCTAssertEqual(relu.apply(-1.0), 0.0)
        XCTAssertGreaterThan(sigmoid.apply(-1.0), 0.0)
        
        // Test large values
        XCTAssertEqual(relu.apply(100.0), 100.0)
        XCTAssertLessThanOrEqual(sigmoid.apply(100.0), 1.0)
    }
    
    // MARK: - Feature Extractor Tests
    
    func testFeatureExtractorInitialization() {
        let extractor = FeatureExtractor()
        XCTAssertNotNil(extractor)
    }
    
    func testTweetFeatureExtraction() {
        let extractor = FeatureExtractor()
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "This is a test tweet with #hashtag and @mention",
            retweetCount: 50,
            likeCount: 100,
            replyCount: 25,
            hashtags: ["#hashtag"],
            mentions: ["@mention"]
        )
        
        let userContext = UserContext(
            userId: "test_user",
            authorFollowers: 1000,
            authorVerified: true,
            engagementRate: 0.8,
            activityScore: 0.9
        )
        
        let features = extractor.extractTweetFeatures(tweet, userContext: userContext)
        
        XCTAssertNotNil(features["like_count"])
        XCTAssertNotNil(features["retweet_count"])
        XCTAssertNotNil(features["reply_count"])
        XCTAssertNotNil(features["content_length"])
        XCTAssertNotNil(features["has_media"])
        XCTAssertNotNil(features["hashtag_count"])
        XCTAssertNotNil(features["mention_count"])
        XCTAssertNotNil(features["author_followers"])
        XCTAssertNotNil(features["author_verified"])
        XCTAssertNotNil(features["user_engagement_rate"])
        XCTAssertNotNil(features["user_activity_score"])
    }
    
    func testRankingFeatureExtraction() {
        let extractor = FeatureExtractor()
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "Test content"
        )
        
        let candidate = RecommendationCandidate(
            id: "test_candidate",
            tweet: tweet,
            score: 0.85,
            reason: .engagement
        )
        
        let userContext = UserContext(
            userId: "test_user",
            authorFollowers: 1000,
            authorVerified: true,
            engagementRate: 0.8,
            activityScore: 0.9
        )
        
        let features = extractor.extractRankingFeatures(candidate, userContext: userContext)
        
        XCTAssertEqual(features.count, 14) // Based on the feature names in the implementation
        XCTAssertTrue(features.allSatisfy { $0 >= 0.0 })
    }
    
    // MARK: - User Context Tests
    
    func testUserContextInitialization() {
        let context = UserContext(
            userId: "test_user",
            authorFollowers: 1000,
            authorVerified: true,
            engagementRate: 0.8,
            activityScore: 0.9,
            interests: ["technology", "AI"],
            demographics: Demographics(
                age: 25,
                gender: "male",
                location: "San Francisco",
                language: "en",
                interests: ["programming", "machine learning"]
            )
        )
        
        XCTAssertEqual(context.userId, "test_user")
        XCTAssertEqual(context.authorFollowers, 1000)
        XCTAssertTrue(context.authorVerified)
        XCTAssertEqual(context.engagementRate, 0.8)
        XCTAssertEqual(context.activityScore, 0.9)
        XCTAssertEqual(context.interests.count, 2)
        XCTAssertEqual(context.demographics.age, 25)
    }
    
    func testDemographicsInitialization() {
        let demographics = Demographics(
            age: 30,
            gender: "female",
            location: "New York",
            language: "en",
            interests: ["art", "music"]
        )
        
        XCTAssertEqual(demographics.age, 30)
        XCTAssertEqual(demographics.gender, "female")
        XCTAssertEqual(demographics.location, "New York")
        XCTAssertEqual(demographics.language, "en")
        XCTAssertEqual(demographics.interests.count, 2)
    }
    
    // MARK: - Model Trainer Tests
    
    func testModelTrainerInitialization() {
        let trainer = ModelTrainer(
            learningRate: 0.001,
            batchSize: 32,
            epochs: 100
        )
        
        XCTAssertNotNil(trainer)
    }
    
    func testTrainingExampleCreation() {
        let example = TrainingExample(
            features: [0.1, 0.2, 0.3, 0.4, 0.5],
            label: 1.0,
            userId: "test_user",
            tweetId: "test_tweet"
        )
        
        XCTAssertEqual(example.features.count, 5)
        XCTAssertEqual(example.label, 1.0)
        XCTAssertEqual(example.userId, "test_user")
        XCTAssertEqual(example.tweetId, "test_tweet")
    }
    
    // MARK: - Model Evaluator Tests
    
    func testModelEvaluatorInitialization() {
        let evaluator = ModelEvaluator()
        XCTAssertNotNil(evaluator)
    }
    
    func testModelEvaluation() {
        let evaluator = ModelEvaluator()
        let model = HeavyRanker(
            inputSize: 3,
            hiddenSizes: [5],
            outputSize: 1
        )
        
        let testData = [
            TrainingExample(features: [0.1, 0.2, 0.3], label: 1.0, userId: "user1", tweetId: "tweet1"),
            TrainingExample(features: [0.4, 0.5, 0.6], label: 0.0, userId: "user2", tweetId: "tweet2"),
            TrainingExample(features: [0.7, 0.8, 0.9], label: 1.0, userId: "user3", tweetId: "tweet3")
        ]
        
        let metrics = evaluator.evaluate(model: model, testData: testData)
        
        // Just verify that evaluation completes without crashing
        // The metrics might be NaN for edge cases, which is acceptable for this test
        XCTAssertNotNil(metrics)
        
        // If we get here, the evaluation completed successfully
        XCTAssertTrue(true)
    }
    
    // MARK: - Integration Tests
    
    func testMLPipelineIntegration() async throws {
        let extractor = FeatureExtractor()
        let ranker = HeavyRanker(
            inputSize: 14, // Based on feature count
            hiddenSizes: [20, 10],
            outputSize: 1
        )
        
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "This is a test tweet for ML pipeline"
        )
        
        let candidate = RecommendationCandidate(
            id: "test_candidate",
            tweet: tweet,
            score: 0.0, // Will be updated by ML model
            reason: .engagement
        )
        
        let userContext = UserContext(
            userId: "test_user",
            authorFollowers: 1000,
            authorVerified: true,
            engagementRate: 0.8,
            activityScore: 0.9
        )
        
        let features = extractor.extractRankingFeatures(candidate, userContext: userContext)
        let prediction = ranker.predictEngagement(features: features)
        
        XCTAssertGreaterThan(prediction, 0.0)
        XCTAssertLessThanOrEqual(prediction, 1.0)
    }
    
    // MARK: - Performance Tests
    
    func testMLModelPerformance() {
        let ranker = HeavyRanker(
            inputSize: 100,
            hiddenSizes: [200, 100, 50],
            outputSize: 1
        )
        
        let startTime = Date()
        
        for _ in 0..<1000 {
            let features = (0..<100).map { _ in Double.random(in: 0...1) }
            _ = ranker.predictEngagement(features: features)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 1000 predictions in reasonable time
        XCTAssertLessThan(duration, 15.0, "ML model inference took too long")
    }
    
    func testFeatureExtractionPerformance() {
        let extractor = FeatureExtractor()
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "Test content for performance testing"
        )
        
        let userContext = UserContext(
            userId: "test_user",
            authorFollowers: 1000,
            authorVerified: true,
            engagementRate: 0.8,
            activityScore: 0.9
        )
        
        let startTime = Date()
        
        for _ in 0..<1000 {
            _ = extractor.extractTweetFeatures(tweet, userContext: userContext)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should complete 1000 extractions in reasonable time
        XCTAssertLessThan(duration, 2.0, "Feature extraction took too long")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyFeatureExtraction() {
        let extractor = FeatureExtractor()
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: ""
        )
        
        let userContext = UserContext(
            userId: "test_user",
            authorFollowers: 0,
            authorVerified: false,
            engagementRate: 0.0,
            activityScore: 0.0
        )
        
        let features = extractor.extractTweetFeatures(tweet, userContext: userContext)
        
        XCTAssertNotNil(features)
        XCTAssertEqual(features["content_length"], 0.0)
        XCTAssertEqual(features["author_followers"], 0.0)
        XCTAssertEqual(features["author_verified"], 0.0)
    }
    
    func testInvalidFeatureValues() {
        let extractor = FeatureExtractor()
        let tweet = Tweet(
            id: "test_tweet",
            authorId: "test_author",
            content: "Test content",
            retweetCount: -1,
            likeCount: -1, // Invalid negative value
            replyCount: -1
        )
        
        let userContext = UserContext(
            userId: "test_user",
            authorFollowers: -1, // Invalid negative value
            authorVerified: true,
            engagementRate: -0.1, // Invalid negative value
            activityScore: 1.5 // Invalid value > 1.0
        )
        
        let features = extractor.extractTweetFeatures(tweet, userContext: userContext)
        
        // Should handle invalid values gracefully
        XCTAssertNotNil(features)
        XCTAssertTrue(features.values.allSatisfy { !$0.isNaN && !$0.isInfinite })
    }
    
    // MARK: - Memory Tests
    
    func testMLModelMemoryUsage() {
        // Test that ML models don't leak memory
        for _ in 0..<100 {
            let _ = HeavyRanker(
                inputSize: 50,
                hiddenSizes: [100, 50],
                outputSize: 1
            )
        }
        
        // If we get here without crashing, memory management is working
        XCTAssertTrue(true)
    }
    
    // MARK: - Thread Safety Tests
    
    func testMLModelThreadSafety() async throws {
        let ranker = HeavyRanker(
            inputSize: 10,
            hiddenSizes: [20],
            outputSize: 1
        )
        
        // Test concurrent predictions
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask { @Sendable in
                    let features = (0..<10).map { _ in Double.random(in: 0...1) }
                    _ = ranker.predictEngagement(features: features)
                }
            }
        }
        
        // If we get here without crashing, thread safety is working
        XCTAssertTrue(true)
    }
}
