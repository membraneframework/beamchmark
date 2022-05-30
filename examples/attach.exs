Beamchmark.run_attached(:example@localhost,
  duration: 5,
  name: "Benchmark attaching to running process.",
  formatters: [Beamchmark.Formatters.HTML]
)
