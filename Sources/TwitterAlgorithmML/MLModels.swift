import Foundation
import Numerics
import TwitterAlgorithmCore

// MARK: - Machine Learning Models

/// Light ranker model for initial candidate filtering
public final class LightRanker {
    private let weights: [String: Double]
    private let bias: Double
    
    public init(weights: [String: Double] = [:], bias: Double = 0.0) {
        self.weights = weights
        self.bias = bias
    }
    
    /// Predict score for a candidate
    public func predict(features: [String: Double]) -> Double {
        var score = bias
        
        for (feature, value) in features {
            if let weight = weights[feature] {
                score += weight * value
            }
        }
        
        return sigmoid(score)
    }
    
    private func sigmoid(_ x: Double) -> Double {
        return 1.0 / (1.0 + exp(-x))
    }
}

/// Heavy ranker model for final ranking
public final class HeavyRanker: @unchecked Sendable {
    private let layers: [NeuralLayer]
    private let inputSize: Int
    private let outputSize: Int
    
    public init(inputSize: Int, hiddenSizes: [Int], outputSize: Int) {
        self.inputSize = inputSize
        self.outputSize = outputSize
        
        var layers: [NeuralLayer] = []
        var currentSize = inputSize
        
        for hiddenSize in hiddenSizes {
            layers.append(NeuralLayer(inputSize: currentSize, outputSize: hiddenSize))
            currentSize = hiddenSize
        }
        
        layers.append(NeuralLayer(inputSize: currentSize, outputSize: outputSize))
        self.layers = layers
    }
    
    /// Forward pass through the network
    public func forward(input: [Double]) -> [Double] {
        var currentInput = input
        
        for layer in layers {
            currentInput = layer.forward(input: currentInput)
        }
        
        return currentInput
    }
    
    /// Predict engagement probability
    public func predictEngagement(features: [Double]) -> Double {
        let output = forward(input: features)
        return sigmoid(output[0])
    }
    
    private func sigmoid(_ x: Double) -> Double {
        return 1.0 / (1.0 + exp(-x))
    }
}

/// Neural network layer
public final class NeuralLayer {
    private let weights: [[Double]]
    private let biases: [Double]
    private let activation: ActivationFunction
    
    public init(inputSize: Int, outputSize: Int, activation: ActivationFunction = .relu) {
        self.activation = activation
        
        // Initialize weights randomly
        var weights: [[Double]] = []
        for _ in 0..<outputSize {
            var row: [Double] = []
            for _ in 0..<inputSize {
                row.append(Double.random(in: -0.1...0.1))
            }
            weights.append(row)
        }
        self.weights = weights
        
        // Initialize biases to zero
        self.biases = Array(repeating: 0.0, count: outputSize)
    }
    
    public func forward(input: [Double]) -> [Double] {
        var output: [Double] = []
        
        for i in 0..<weights.count {
            var sum = biases[i]
            for j in 0..<input.count {
                sum += weights[i][j] * input[j]
            }
            output.append(activation.apply(sum))
        }
        
        return output
    }
}

/// Activation functions
public enum ActivationFunction {
    case relu
    case sigmoid
    case tanh
    case linear
    
    public func apply(_ x: Double) -> Double {
        switch self {
        case .relu:
            return max(0, x)
        case .sigmoid:
            return 1.0 / (1.0 + exp(-x))
        case .tanh:
            return Foundation.tanh(x)
        case .linear:
            return x
        }
    }
}

/// Feature extractor for ML models
public final class FeatureExtractor {
    private let config: FeatureExtractionConfiguration
    
    public init(config: FeatureExtractionConfiguration = .default) {
        self.config = config
    }
    
    /// Extract features for a tweet
    public func extractTweetFeatures(_ tweet: Tweet, userContext: UserContext) -> [String: Double] {
        var features: [String: Double] = [:]
        
        // Engagement features
        features["like_count"] = Double(tweet.likeCount)
        features["retweet_count"] = Double(tweet.retweetCount)
        features["reply_count"] = Double(tweet.replyCount)
        features["quote_count"] = Double(tweet.quoteCount)
        
        // Temporal features
        let hoursSinceCreation = Date().timeIntervalSince(tweet.createdAt) / 3600
        features["hours_since_creation"] = hoursSinceCreation
        features["is_recent"] = hoursSinceCreation < 24 ? 1.0 : 0.0
        
        // Content features
        features["content_length"] = Double(tweet.content.count)
        features["has_media"] = tweet.mediaURLs.isEmpty ? 0.0 : 1.0
        features["hashtag_count"] = Double(tweet.hashtags.count)
        features["mention_count"] = Double(tweet.mentions.count)
        
        // Author features
        features["author_followers"] = Double(userContext.authorFollowers)
        features["author_verified"] = userContext.authorVerified ? 1.0 : 0.0
        
        // User interaction features
        features["user_engagement_rate"] = userContext.engagementRate
        features["user_activity_score"] = userContext.activityScore
        
        return features
    }
    
    /// Extract features for ranking
    public func extractRankingFeatures(_ candidate: RecommendationCandidate, userContext: UserContext) -> [Double] {
        let tweetFeatures = extractTweetFeatures(candidate.tweet, userContext: userContext)
        
        // Convert to array format for neural network
        let featureNames = [
            "like_count", "retweet_count", "reply_count", "quote_count",
            "hours_since_creation", "is_recent", "content_length",
            "has_media", "hashtag_count", "mention_count",
            "author_followers", "author_verified",
            "user_engagement_rate", "user_activity_score"
        ]
        
        return featureNames.map { tweetFeatures[$0] ?? 0.0 }
    }
}

/// User context for feature extraction
public struct UserContext {
    public let userId: String
    public let authorFollowers: Int
    public let authorVerified: Bool
    public let engagementRate: Double
    public let activityScore: Double
    public let interests: [String]
    public let demographics: Demographics
    
    public init(
        userId: String,
        authorFollowers: Int = 0,
        authorVerified: Bool = false,
        engagementRate: Double = 0.0,
        activityScore: Double = 0.0,
        interests: [String] = [],
        demographics: Demographics = Demographics()
    ) {
        self.userId = userId
        self.authorFollowers = authorFollowers
        self.authorVerified = authorVerified
        self.engagementRate = engagementRate
        self.activityScore = activityScore
        self.interests = interests
        self.demographics = demographics
    }
}

/// User demographics
public struct Demographics: Codable {
    public let age: Int?
    public let gender: String?
    public let location: String?
    public let language: String?
    public let interests: [String]
    
    public init(
        age: Int? = nil,
        gender: String? = nil,
        location: String? = nil,
        language: String? = nil,
        interests: [String] = []
    ) {
        self.age = age
        self.gender = gender
        self.location = location
        self.language = language
        self.interests = interests
    }
}

/// Feature extraction configuration
public struct FeatureExtractionConfiguration: Codable, Sendable {
    public let enableEngagementFeatures: Bool
    public let enableTemporalFeatures: Bool
    public let enableContentFeatures: Bool
    public let enableAuthorFeatures: Bool
    public let enableUserFeatures: Bool
    public let normalizeFeatures: Bool
    
    public init(
        enableEngagementFeatures: Bool = true,
        enableTemporalFeatures: Bool = true,
        enableContentFeatures: Bool = true,
        enableAuthorFeatures: Bool = true,
        enableUserFeatures: Bool = true,
        normalizeFeatures: Bool = true
    ) {
        self.enableEngagementFeatures = enableEngagementFeatures
        self.enableTemporalFeatures = enableTemporalFeatures
        self.enableContentFeatures = enableContentFeatures
        self.enableAuthorFeatures = enableAuthorFeatures
        self.enableUserFeatures = enableUserFeatures
        self.normalizeFeatures = normalizeFeatures
    }
    
    public static let `default` = FeatureExtractionConfiguration()
}

/// Model trainer for updating ML models
public final class ModelTrainer {
    private let learningRate: Double
    private let batchSize: Int
    private let epochs: Int
    
    public init(learningRate: Double = 0.001, batchSize: Int = 32, epochs: Int = 100) {
        self.learningRate = learningRate
        self.batchSize = batchSize
        self.epochs = epochs
    }
    
    /// Train a neural network model
    public func train(model: HeavyRanker, trainingData: [TrainingExample]) async throws {
        // Simplified training loop
        for epoch in 0..<epochs {
            let batches = createBatches(from: trainingData, batchSize: batchSize)
            
            for batch in batches {
                try await trainBatch(model: model, batch: batch)
            }
            
            if epoch % 10 == 0 {
                print("Epoch \(epoch) completed")
            }
        }
    }
    
    private func createBatches(from data: [TrainingExample], batchSize: Int) -> [[TrainingExample]] {
        var batches: [[TrainingExample]] = []
        
        for i in stride(from: 0, to: data.count, by: batchSize) {
            let endIndex = min(i + batchSize, data.count)
            let batch = Array(data[i..<endIndex])
            batches.append(batch)
        }
        
        return batches
    }
    
    private func trainBatch(model: HeavyRanker, batch: [TrainingExample]) async throws {
        // Simplified batch training
        for example in batch {
            let prediction = model.predictEngagement(features: example.features)
            let _ = example.label - prediction
            
            // Update model weights (simplified)
            // In a real implementation, this would use backpropagation
        }
    }
}

/// Training example for ML models
public struct TrainingExample {
    public let features: [Double]
    public let label: Double
    public let userId: String
    public let tweetId: String
    
    public init(features: [Double], label: Double, userId: String, tweetId: String) {
        self.features = features
        self.label = label
        self.userId = userId
        self.tweetId = tweetId
    }
}

/// Model evaluation metrics
public struct ModelMetrics {
    public let accuracy: Double
    public let precision: Double
    public let recall: Double
    public let f1Score: Double
    public let auc: Double
    
    public init(accuracy: Double, precision: Double, recall: Double, f1Score: Double, auc: Double) {
        self.accuracy = accuracy
        self.precision = precision
        self.recall = recall
        self.f1Score = f1Score
        self.auc = auc
    }
}

/// Model evaluator
public final class ModelEvaluator {
    public init() {}
    
    /// Evaluate model performance
    public func evaluate(model: HeavyRanker, testData: [TrainingExample]) -> ModelMetrics {
        var correctPredictions = 0
        var truePositives = 0
        var falsePositives = 0
        var falseNegatives = 0
        var trueNegatives = 0
        
        for example in testData {
            let prediction = model.predictEngagement(features: example.features)
            let predictedLabel = prediction > 0.5 ? 1.0 : 0.0
            
            if predictedLabel == example.label {
                correctPredictions += 1
            }
            
            if predictedLabel == 1.0 && example.label == 1.0 {
                truePositives += 1
            } else if predictedLabel == 1.0 && example.label == 0.0 {
                falsePositives += 1
            } else if predictedLabel == 0.0 && example.label == 1.0 {
                falseNegatives += 1
            } else {
                trueNegatives += 1
            }
        }
        
        let accuracy = Double(correctPredictions) / Double(testData.count)
        let precision = Double(truePositives) / Double(truePositives + falsePositives)
        let recall = Double(truePositives) / Double(truePositives + falseNegatives)
        let f1Score = 2 * (precision * recall) / (precision + recall)
        
        return ModelMetrics(
            accuracy: accuracy,
            precision: precision,
            recall: recall,
            f1Score: f1Score,
            auc: 0.0 // Simplified - would need proper AUC calculation
        )
    }
}
