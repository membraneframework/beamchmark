# Beamchmark
[![Hex.pm](https://img.shields.io/hexpm/v/beamchmark.svg)](https://hex.pm/packages/beamchmark)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/beamchmark)
[![CircleCI](https://circleci.com/gh/membraneframework/beamchmark.svg?style=svg)](https://circleci.com/gh/membraneframework/beamchmark)

Tool for measuring EVM performance.

At the moment, the main interest of Beamchmark is scheduler utilization, reductions and the number of context switches.
For more information please refer to API docs.
Currently, Beamchmark is supported on macOS, Linux and partially on Windows.

## Beamchmark and Benchee
Beamchmark should be used when you want to measure BEAM performance while it is running your application.
Benchee should be used when you want to benchmark specific function from your code base.
In particular, Benchee will inform you how long your function is executing, while Beamchmark will inform you
how busy BEAM is.

## Installation
The package can be installed by adding `beamchmark` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beamchmark, "~> 1.4.0"}
  ]
end
```

## Usage

### Running an application using `Beamchmark.Scenario`

You create a test scenario by adopting `Beamchmark.Scenario` behaviour in a module. It has to implement `run()` function, which will execute for benchmarking.

The examples of using `Scenario` are located in the `examples` directory.
To run one of them, simply use the following command: 

```bash
mix run examples/<example_name>.exs
```

### Running Beamchmark in an attached mode

If you want to measure the performance of an already running BEAM you can run Beamchmark in an attached mode.
However, it is required that the node on which your application is running is a distributed node and has `Beamchmark` added to its dependencies.

To run an example of Beamchmark in attached mode first start the node, which performance will be measured:
```bash
cd examples/attached
mix deps.get
elixir --sname counter@localhost -S mix run start_counter.exs
```
The node will be visible under `counter@localhost` name.

Now in another terminal you can start the benchmark:
```bash
epmd -daemon 
mix run examples/attached/run_attached.exs
```

## Formatters
You can output benchmark results with Beamchmark's built-in formatters or implement a custom one.
Formatters can also compare new results with the previous ones, given they share the same scenario module and 
were configured to run for the same amount of time.

Currently, you can output Beamchmark reports in the following ways:
* `Beamchmark.Formatters.Console`

  This is the default formatter, it will print the report on standard output.

  ```txt
  ================
  SYSTEM INFO
  ================

  Elixir version: 1.13.4
  OTP version: 24
  OS: macOS
  Memory: 16 GB
  System arch: x86_64-apple-darwin21.3.0
  NIF version: 2.16
  Cores: 8

  ================
  CONFIGURATION
  ================

  Delay: 5s
  Duration: 15s

  ================
  MEASUREMENTS
  ================

  Normal schedulers
  --------------------
  1 0.7462382700312585 74.6%
  2 0.7552131238891551 75.5%
  3 0.7080346117265083 70.8%
  4 0.6840002812013201 68.4%
  5 0.7357487054135822 73.6%
  6 0.7889711402496832 78.9%
  7 0.7053186570052465 70.5%
  8 0.495807853995791 49.6%
  Total: 0.7024165804390681 70.2%

  CPU schedulers
  --------------------
  9 0.39409732340500314 39.4%
  10 0.5194739765841625 51.9%
  11 0.45208160433332006 45.2%
  12 0.33614215325750824 33.6%
  13 0.05474778835410803 5.5%
  14 0.31687236471324787 31.7%
  15 0.06046101946449905 6.0%
  16 0.0 0.0%
  Total: 0.2667345287639811 26.7%

  IO schedulers
  --------------------
  17 0.0 0.0%
  18 0.0 0.0%
  19 0.0 0.0%
  20 0.0 0.0%
  21 0.0 0.0%
  22 0.0 0.0%
  23 0.0 0.0%
  24 0.0 0.0%
  25 2.7705124922689514e-4 0.0%
  26 0.0 0.0%
  Total: 2.7705124922689516e-5 0.0%

  Weighted
  --------------------
  0.9692071705951804 96.9%


  Reductions
  --------------------
  2847054520

  Context Switches
  --------------------
  717845

  CPU Usage Average
  --------------------
  51.2%

  CPU Usage Per Core
  --------------------
  Core: 0 -> 99.81 %
  Core: 1 -> 2.84 %
  Core: 2 -> 99.81 %
  Core: 3 -> 2.57 %
  Core: 4 -> 99.82 %
  Core: 5 -> 2.23 %
  Core: 6 -> 99.88 %
  Core: 7 -> 2.6 %

  Memory usage
  --------------------
  3.56 GB

  ================
  NEW MEASUREMENTS
  ================

  Normal schedulers
  --------------------
  1 0.7391849466705548 73.9%  -0.007053323360703745 -0.9383378016085686%
  2 0.6451374210660318 64.5%  -0.11007570282312329 -14.569536423841058%
  3 0.612116497924041 61.2%  -0.09591811380246729 -13.559322033898297%
  4 0.7119528248221814 71.2%  0.027952543620861303 4.093567251461991%
  5 0.7175675964576803 71.8%  -0.01818110895590186 -2.4456521739130324%
  6 0.667647106911744 66.8%  -0.12132403333793917 -15.335868187579223%
  7 0.7588791891435591 75.9%  0.05356053213831258 7.659574468085111%
  8 0.7007975884343178 70.1%  0.2049897344385268 41.330645161290306%
  Total: 0.6941603964287638 69.4%  -0.008256184010304257 -1.139601139601126%

  CPU schedulers
  --------------------
  9 0.40317586539492 40.3%  0.009078541989916866 2.284263959390856%
  10 0.0658197960010861 6.6%  -0.4536541805830764 -87.28323699421965%
  11 0.207488920931131 20.7%  -0.24459268340218907 -54.20353982300885%
  12 0.4070941615062336 40.7%  0.07095200824872538 21.130952380952394%
  13 0.5912324517586194 59.1%  0.5364846634045114 974.5454545454545%
  14 4.213003273973723e-8 0.0%  -0.3168723225832151 -100%
  15 0.5185116282961778 51.9%  0.45805060883167875 765.0%
  16 0.014049861167737257 1.4%  0.014049861167737257 nan
  Total: 0.27592159089824225 27.6%  0.009187062134261126 3.37078651685394%

  IO schedulers
  --------------------
  17 0.0 0.0%  0.0 0%
  18 0.0 0.0%  0.0 0%
  19 0.0 0.0%  0.0 0%
  20 0.0 0.0%  0.0 0%
  21 0.0 0.0%  0.0 0%
  22 0.0 0.0%  0.0 0%
  23 0.0 0.0%  0.0 0%
  24 0.0 0.0%  0.0 0%
  25 0.0 0.0%  -2.7705124922689514e-4 0%
  26 2.2108785953999204e-4 0.0%  2.2108785953999204e-4 0%
  Total: 2.2108785953999205e-5 0.0%  -5.596338968690311e-6 0%

  Weighted
  --------------------
  0.9700717546422247 97.0%  8.6458404704437e-4 0.10319917440659765%


  Reductions
  --------------------
  2621243405  -225811115 -7.931394127289138%

  Context Switches
  --------------------
  666449  -51396 -7.159762901462017%

  CPU Usage Average
  --------------------
  51.88%  0.68% 1.34%

  CPU Usage Per Core
  --------------------
  Core 0 -> 99.74%  -0.07 -0.07 %
  Core 1 -> 4.35%  1.51 53.17 %
  Core 2 -> 99.83%  0.01 0.01 %
  Core 3 -> 3.96%  1.39 53.96 %
  Core 4 -> 99.82%  0.01 0.01 %
  Core 5 -> 3.75%  1.52 68.44 %
  Core 6 -> 99.76%  -0.12 -0.12 %
  Core 7 -> 3.83%  1.22 46.91 %

  Memory usage
  --------------------
  3.58 GB  21.96 MB 0.6%
  ```

* `Beamchmark.Formatters.HTML`

  The HTML formatter will save the report to an HTML file.
  
  ![Screenshot of an HTML report](https://user-images.githubusercontent.com/48837433/172619856-44e1280d-b361-4fb9-941a-11c83bde6e47.png)


* Custom formatters

  You can implement your custom formatters by overriding `Beamchmark.Formatter` behaviour.

## Copyright and License
Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
