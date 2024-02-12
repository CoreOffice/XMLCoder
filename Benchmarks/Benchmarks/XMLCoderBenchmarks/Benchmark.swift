import Benchmark

let benchmarks = {
    Benchmark(
        "XMLDecoder",
        configuration: .init(
            metrics: [
                .throughput
            ]
        )
    ) { benchmark in
        try runXMLDecoder()
    }
}