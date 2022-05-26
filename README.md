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
    {:beamchmark, "~> 1.3.0"}
  ]
end
```

## Usage
To run an example, simply use the following command: 

```bash
mix run examples/<example_name>.exs
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

  Elixir version: 1.13.3
  OTP version: 24
  OS: macOS
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
  1 0.7567087990844555 75.7%
  2 0.7743861492248577 77.4%
  3 0.7621129371697227 76.2%
  4 0.8118439570950331 81.2%
  5 0.6917622649678838 69.2%
  6 0.8363837341609188 83.6%
  7 0.7979361712650317 79.8%
  8 0.6551890519401764 65.5%
  Total: 0.76079038311351 76.1%

  CPU schedulers
  --------------------
  9 0.3334018309321515 33.3%
  10 0.20471634962143134 20.5%
  11 0.19498600242792105 19.5%
  12 0.0 0.0%
  13 0.29595633128396 29.6%
  14 0.27764289697785616 27.8%
  15 0.28564711801185355 28.6%
  16 0.0 0.0%
  Total: 0.1990438161568967 19.9%

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
  25 0.0 0.0%
  26 0.00122675800153823 0.1%
  Total: 1.22675800153823e-4 0.0%

  Weighted
  --------------------
  0.9598352941324481 96.0%


  Reductions
  --------------------
  3329169211

  Context Switches
  --------------------
  847934

  CPU Usage Average
  --------------------
  87.05%

  CPU Usage Per Core
  --------------------
  Core: 0 -> 96.89 %
  Core: 1 -> 80.76 %
  Core: 2 -> 96.0 %
  Core: 3 -> 76.32 %
  Core: 4 -> 96.05 %
  Core: 5 -> 76.34 %
  Core: 6 -> 96.19 %
  Core: 7 -> 77.82 %

  ================
  NEW MEASUREMENTS
  ================

  Normal schedulers
  --------------------
  1 0.7645594929453556 76.5%  0.007850693860900093 1.056803170409509%
  2 0.8067833341020048 80.7%  0.032397184877147045 4.263565891472851%
  3 0.7301987549092894 73.0%  -0.0319141822604333 -4.199475065616795%
  4 0.7756702242407342 77.6%  -0.03617373285429892 -4.433497536945822%
  5 0.7981660676392356 79.8%  0.10640380267135174 15.317919075144502%
  6 0.7934219388759585 79.3%  -0.04296179528496036 -5.143540669856463%
  7 0.7605955534435537 76.1%  -0.03734061782147802 -4.636591478696744%
  8 0.6778514266580629 67.8%  0.022662374717886458 3.5114503816793956%
  Total: 0.7634058491017743 76.3%  0.0026154659882643427 0.26281208935611744%

  CPU schedulers
  --------------------
  9 0.32460031472430834 32.5%  -0.00880151620784314 -2.4024024024023873%
  10 0.29100581748775994 29.1%  0.0862894678663286 41.95121951219514%
  11 0.0 0.0%  -0.19498600242792105 -100%
  12 0.20866165715002463 20.9%  0.20866165715002463 nan
  13 0.17782563238945143 17.8%  -0.11813069889450856 -39.86486486486487%
  14 0.39312819713730307 39.3%  0.11548530015944691 41.36690647482013%
  15 0.0 0.0%  -0.28564711801185355 -100%
  16 0.24205159833788348 24.2%  0.24205159833788348 nan
  Total: 0.20465915215334135 20.5%  0.005615335996444648 3.0150753768844396%

  IO schedulers
  --------------------
  17 0.0 0.0%  0.0 0%
  18 0.0 0.0%  0.0 0%
  19 0.0 0.0%  0.0 0%
  20 0.0 0.0%  0.0 0%
  21 0.0012609101653325884 0.1%  0.0012609101653325884 nan
  22 0.0 0.0%  0.0 0%
  23 0.0 0.0%  0.0 0%
  24 0.0 0.0%  0.0 0%
  25 0.0 0.0%  0.0 0%
  26 0.0 0.0%  -0.00122675800153823 -100%
  Total: 1.2609101653325883e-4 0.0%  3.415216379435847e-6 0%

  Weighted
  --------------------
  0.9680642119552599 96.8%  0.008228917822811876 0.8333333333333286%


  Reductions
  --------------------
  3136003725  -193165486 -5.802212917317533%

  Context Switches
  --------------------
  798420  -49514 -5.839369573575297%

  CPU Usage Average
  --------------------
  87.83%  0.78% 0.89%


  CPU Usage Per Core
  --------------------
  Core 0 -> 97.56%  0.66 0.68 %
  Core 1 -> 81.02%  0.26 0.32 %
  Core 2 -> 97.03%  1.03 1.07 %
  Core 3 -> 76.33%  0.01 0.01 %
  Core 4 -> 97.36%  1.3 1.36 %
  Core 5 -> 76.93%  0.59 0.78 %
  Core 6 -> 97.28%  1.1 1.14 %
  Core 7 -> 79.1%  1.28 1.65 %
  ```

* `Beamchmark.Formatters.HTML`

  The HTML formatter will save the report to an HTML file.
  
  ![Screenshot of an HTML report](https://user-images.githubusercontent.com/57190429/159237561-ed0ef956-e78d-4423-afd3-13860d39099b.png)


* Custom formatters

  You can implement your custom formatters by overriding `Beamchmark.Formatter` behaviour.

## Copyright and License
Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
