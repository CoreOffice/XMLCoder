// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "benchmarks",
    platforms: [
        .macOS("14"),
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.22.0"),
    ],
    targets: [
        .executableTarget(
            name: "XMLCoderBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "XMLCoder", package: "XMLCoder"),
            ],
            path: "Benchmarks/XMLCoderBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        ),
    ]
)