import Foundation

// MARK: - Build Analysis Types

public struct BuildAnalysis {
    public let buildTime: TimeInterval
    public let bundleSize: Int
    public let dependencies: [DependencyInfo]
    public let warnings: [String]
    public let optimization: OptimizationReport
    public let performance: PerformanceMetrics
    
    public var bundleSizeKB: Double {
        return Double(bundleSize) / 1024.0
    }
    
    public var grade: BuildGrade {
        if buildTime < 1.0 && bundleSizeKB < 100 {
            return .excellent
        } else if buildTime < 2.0 && bundleSizeKB < 200 {
            return .good
        } else if buildTime < 5.0 && bundleSizeKB < 500 {
            return .fair
        } else {
            return .needsImprovement
        }
    }
}

public struct DependencyInfo {
    public let name: String
    public let size: Int
    public let version: String?
    public let isVendor: Bool
    
    public var sizeKB: Double {
        return Double(size) / 1024.0
    }
}

public struct OptimizationReport {
    public let minificationSavings: Int
    public let deadCodeEliminationSavings: Int
    public let treeshakingSavings: Int
    public let compressionRatio: Double
    public let suggestions: [String]
    
    public var totalSavings: Int {
        return minificationSavings + deadCodeEliminationSavings + treeshakingSavings
    }
    
    public var totalSavingsKB: Double {
        return Double(totalSavings) / 1024.0
    }
}

public struct PerformanceMetrics {
    public let parseTime: TimeInterval
    public let transformTime: TimeInterval
    public let bundleTime: TimeInterval
    public let writeTime: TimeInterval
    public let memoryUsage: Int
    
    public var totalTime: TimeInterval {
        return parseTime + transformTime + bundleTime + writeTime
    }
}

public enum BuildGrade: String, CaseIterable {
    case excellent = "A+"
    case good = "B+"
    case fair = "C+"
    case needsImprovement = "D"
    
    public var emoji: String {
        switch self {
        case .excellent: return "🚀"
        case .good: return "✅"
        case .fair: return "⚠️"
        case .needsImprovement: return "🐌"
        }
    }
    
    public var description: String {
        switch self {
        case .excellent: return "Excellent - Fast builds, small bundles"
        case .good: return "Good - Solid performance"
        case .fair: return "Fair - Room for improvement"
        case .needsImprovement: return "Needs Improvement - Consider optimization"
        }
    }
}

// MARK: - Build Analyzer

public class BuildAnalyzer {
    
    public static let shared = BuildAnalyzer()
    private var buildHistory: [BuildAnalysis] = []
    private let maxHistorySize = 50
    
    private init() {}
    
    public func analyzeBuild(_ result: BuildResult, framework: FrameworkKind) -> BuildAnalysis {
        let dependencies = extractDependencies(from: result, framework: framework)
        let optimization = analyzeOptimization(result)
        let performance = analyzePerformance(result)
        
        let analysis = BuildAnalysis(
            buildTime: TimeInterval(result.durationMs) / 1000.0,
            bundleSize: result.bytes,
            dependencies: dependencies,
            warnings: result.warnings,
            optimization: optimization,
            performance: performance
        )
        
        addToHistory(analysis)
        return analysis
    }
    
    private func extractDependencies(from result: BuildResult, framework: FrameworkKind) -> [DependencyInfo] {
        var dependencies: [DependencyInfo] = []
        
        // Common vendor dependencies based on framework
        switch framework {
        case .reactThreeFiber:
            dependencies.append(contentsOf: [
                DependencyInfo(name: "react", size: 10737, version: "18.2.0", isVendor: true),
                DependencyInfo(name: "react-dom", size: 131882, version: "18.2.0", isVendor: true),
                DependencyInfo(name: "three", size: 1272972, version: "r160", isVendor: true),
                DependencyInfo(name: "@react-three/fiber", size: 50000, version: "8.15+", isVendor: true),
                DependencyInfo(name: "@react-three/drei", size: 80000, version: "9.88+", isVendor: true)
            ])
            
        case .reactylon:
            dependencies.append(contentsOf: [
                DependencyInfo(name: "react", size: 10737, version: "18.2.0", isVendor: true),
                DependencyInfo(name: "react-dom", size: 131882, version: "18.2.0", isVendor: true),
                DependencyInfo(name: "@babylonjs/core", size: 2000000, version: "6.0+", isVendor: true),
                DependencyInfo(name: "reactylon", size: 120000, version: "1.0+", isVendor: true)
            ])
            
        case .babylon:
            dependencies.append(
                DependencyInfo(name: "@babylonjs/core", size: 2000000, version: "6.0+", isVendor: true)
            )
            
        case .aFrame:
            dependencies.append(
                DependencyInfo(name: "aframe", size: 800000, version: "1.4+", isVendor: true)
            )
        }
        
        return dependencies
    }
    
    private func analyzeOptimization(_ result: BuildResult) -> OptimizationReport {
        let bundleSize = result.bytes
        let estimatedUnminifiedSize = Int(Double(bundleSize) * 2.5) // Rough estimate
        
        let minificationSavings = estimatedUnminifiedSize - bundleSize
        let deadCodeSavings = Int(Double(bundleSize) * 0.1) // Estimate
        let treeshakingSavings = Int(Double(bundleSize) * 0.05) // Estimate
        
        var suggestions: [String] = []
        
        if bundleSize > 500_000 { // 500KB
            suggestions.append("Consider code splitting for large bundles")
        }
        
        if bundleSize > 200_000 { // 200KB
            suggestions.append("Enable minification to reduce bundle size")
        }
        
        if result.warnings.isEmpty && bundleSize > 100_000 {
            suggestions.append("Consider dynamic imports for rarely used features")
        }
        
        if !result.warnings.isEmpty {
            suggestions.append("Review warnings for potential optimizations")
        }
        
        return OptimizationReport(
            minificationSavings: minificationSavings,
            deadCodeEliminationSavings: deadCodeSavings,
            treeshakingSavings: treeshakingSavings,
            compressionRatio: Double(estimatedUnminifiedSize) / Double(bundleSize),
            suggestions: suggestions
        )
    }
    
    private func analyzePerformance(_ result: BuildResult) -> PerformanceMetrics {
        let totalTime = TimeInterval(result.durationMs) / 1000.0
        
        // Estimate breakdown (would be real in Node.js implementation)
        let parseTime = totalTime * 0.2
        let transformTime = totalTime * 0.4
        let bundleTime = totalTime * 0.3
        let writeTime = totalTime * 0.1
        
        return PerformanceMetrics(
            parseTime: parseTime,
            transformTime: transformTime,
            bundleTime: bundleTime,
            writeTime: writeTime,
            memoryUsage: result.bytes * 3 // Rough estimate
        )
    }
    
    private func addToHistory(_ analysis: BuildAnalysis) {
        buildHistory.append(analysis)
        
        if buildHistory.count > maxHistorySize {
            buildHistory.removeFirst()
        }
    }
    
    // MARK: - Analytics and Insights
    
    public func getBuildTrends() -> BuildTrends {
        guard buildHistory.count >= 3 else {
            return BuildTrends(
                averageBuildTime: 0,
                averageBundleSize: 0,
                buildTimetrend: .stable,
                bundleSizetrend: .stable,
                recentBuilds: buildHistory
            )
        }
        
        let recent = buildHistory.suffix(10)
        let averageBuildTime = recent.map(\.buildTime).reduce(0, +) / Double(recent.count)
        let averageBundleSize = recent.map(\.bundleSize).reduce(0, +) / recent.count
        
        // Calculate trends
        let recentBuildTimes = recent.map(\.buildTime)
        let recentBundleSizes = recent.map(\.bundleSize)
        
        let buildTimetrend = calculateTrend(values: recentBuildTimes)
        let bundleSizetrend = calculateTrend(values: recentBundleSizes.map(Double.init))
        
        return BuildTrends(
            averageBuildTime: averageBuildTime,
            averageBundleSize: averageBundleSize,
            buildTimetrend: buildTimetrend,
            bundleSizetrend: bundleSizetrend,
            recentBuilds: Array(recent)
        )
    }
    
    private func calculateTrend(values: [Double]) -> Trend {
        guard values.count >= 3 else { return .stable }
        
        let first = values.prefix(values.count / 2).reduce(0, +) / Double(values.count / 2)
        let last = values.suffix(values.count / 2).reduce(0, +) / Double(values.count / 2)
        
        let change = (last - first) / first
        
        if change > 0.1 {
            return .increasing
        } else if change < -0.1 {
            return .decreasing
        } else {
            return .stable
        }
    }
    
    public func getOptimizationRecommendations() -> [String] {
        let recent = buildHistory.suffix(5)
        var recommendations: [String] = []
        
        let averageSize = recent.map(\.bundleSize).reduce(0, +) / recent.count
        let averageTime = recent.map(\.buildTime).reduce(0, +) / Double(recent.count)
        
        if averageSize > 300_000 { // 300KB
            recommendations.append("📦 Bundle size is large - consider code splitting")
        }
        
        if averageTime > 3.0 {
            recommendations.append("⏱️ Build time is slow - enable caching or use Node.js worker")
        }
        
        let recentGrades = recent.map(\.grade)
        let poorGrades = recentGrades.filter { $0 == .needsImprovement || $0 == .fair }
        
        if Double(poorGrades.count) / Double(recentGrades.count) > 0.5 {
            recommendations.append("🎯 Build performance needs attention - review optimization settings")
        }
        
        return recommendations
    }
}

// MARK: - Build Trends

public struct BuildTrends {
    public let averageBuildTime: TimeInterval
    public let averageBundleSize: Int
    public let buildTimetrend: Trend
    public let bundleSizetrend: Trend
    public let recentBuilds: [BuildAnalysis]
    
    public var averageBundleSizeKB: Double {
        return Double(averageBundleSize) / 1024.0
    }
}

public enum Trend {
    case increasing
    case decreasing
    case stable
    
    public var emoji: String {
        switch self {
        case .increasing: return "📈"
        case .decreasing: return "📉"
        case .stable: return "➡️"
        }
    }
    
    public var description: String {
        switch self {
        case .increasing: return "Increasing"
        case .decreasing: return "Decreasing"
        case .stable: return "Stable"
        }
    }
}

// MARK: - Enhanced Build Result

extension BuildResult {
    public func analyze(for framework: FrameworkKind) -> BuildAnalysis {
        return BuildAnalyzer.shared.analyzeBuild(self, framework: framework)
    }
}