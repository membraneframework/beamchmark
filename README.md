# Beamchmark
[![Hex.pm](https://img.shields.io/hexpm/v/beamchmark.svg)](https://hex.pm/packages/beamchmark)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/beamchmark)
[![CircleCI](https://circleci.com/gh/membraneframework/beamchmark.svg?style=svg)](https://circleci.com/gh/membraneframework/beamchmark)

Tool for measuring EVM performance.

At the moment, the main interest of Beamchmark is scheduler utilization, reductions and the number of context switches.
For more information please refer to API docs.

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
    {:beamchmark, "~> 0.1.1"}
  ]
end
```

## Usage
To run an example, simply use the following command: 

```bash
mix run examples/<example_name>.exs
```

## Formatters
Currently, Beamchmark supports two ways of printing its reports:
* `Beamchmark.Formatters.Console`

  This is the default formatter, it will print the report on standard output.

  ```txt
  > mix run examples/advanced.exs

  Running scenario "AdvancedScenario"...
  Waiting 5 seconds...
  Benchmarking for 15 seconds...
  Results successfully saved to "/tmp/beamchmark_output" directory.
  ================
  SYSTEM INFO
  ================

  Elixir version: 1.13.3
  OTP version: 24
  OS: macOS
  System arch: aarch64-apple-darwin21.1.0
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
  1 0.7020763014639843 70.2%
  2 0.6767303549926615 67.7%
  3 0.7163657988707101 71.6%
  4 0.6820129497429184 68.2%
  5 0.7056747696775519 70.6%
  6 0.6582191381763732 65.8%
  7 0.5866170837683002 58.7%
  8 0.21022401386144263 21.0%
  Total: 0.6172400513192429 61.7%

  CPU schedulers
  --------------------
  9 0.0 0.0%
  10 0.0 0.0%
  11 0.17425219168387035 17.4%
  12 0.3033345203543891 30.3%
  13 0.1410712973909046 14.1%
  14 0.24115177128561846 24.1%
  15 0.3105390404381321 31.1%
  16 0.27138609560062016 27.1%
  Total: 0.18021686459419187 18.0%

  IO schedulers
  --------------------

  Total: 0 0%

  Weighted
  --------------------
  0.7974559085619839 79.7%


  Reductions
  --------------------
  5616394756

  Context Switches
  --------------------
  1428412

  ================
  NEW MEASUREMENTS
  ================

  Normal schedulers
  --------------------
  1 0.711089161283597 71.1%  0.00901285981961275 1.2820512820512704%
  2 0.6641681737630784 66.4%  -0.012562181229583191 -1.920236336779908%
  3 0.7106285043485066 71.1%  -0.0057372945222035066 -0.6983240223463696%
  4 0.70753393024408 70.8%  0.025520980501161583 3.812316715542522%
  5 0.6840751352002755 68.4%  -0.02159963447727642 -3.116147308781862%
  6 0.671931312310082 67.2%  0.013712174133708732 2.1276595744680975%
  7 0.5639523157401223 56.4%  -0.022664768028177962 -3.9182282793867103%
  8 0.18621091185400204 18.6%  -0.024013102007440584 -11.428571428571416%
  Total: 0.612448680592968 61.2%  -0.004791370726274891 -0.8103727714748743%

  CPU schedulers
  --------------------
  9 0.3204327904290152 32.0%  0.3204327904290152 nan
  10 0.3060191309572284 30.6%  0.3060191309572284 nan
  11 0.19581858685194856 19.6%  0.021566395168078206 12.643678160919563%
  12 0.28379457620982024 28.4%  -0.019539944144568888 -6.270627062706282%
  13 0.23252541122737072 23.3%  0.09145411383646612 65.24822695035462%
  14 0.0 0.0%  -0.24115177128561846 -100%
  15 0.0 0.0%  -0.3105390404381321 -100%
  16 0.05489916160857257 5.5%  -0.2164869339920476 -79.70479704797049%
  Total: 0.17418620716049446 17.4%  -0.006030657433697406 -3.333333333333343%

  IO schedulers
  --------------------

  Total: 0 0%  0 0%

  Weighted
  --------------------
  0.7866289232807818 78.7%  -0.010826985281202073 -1.2547051442910941%


  Reductions
  --------------------
  5613002284  -3392472 -0.06040301914988788%

  Context Switches
  --------------------
  1428303  -109 -0.007630851603039446%
  ```

* `Beamchmark.Formatters.HTML`

  The HTML formatter will save the report to an HTML file.
  
  ![Screenshot of an HTML report](https://user-images.githubusercontent.com/31112335/157019137-0f7dd5f9-d59a-4656-9bee-8ec84e482169.png)

* Custom formatters

  You can implement your custom formatters by overriding `Beamchmark.Formatter` behaviour.

## Copyright and License
Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
