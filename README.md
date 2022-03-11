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
    {:beamchmark, "~> 1.0"}
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
  1 0.7958169880265962 79.6%
  2 0.7427647871810756 74.3%
  3 0.7436443097244569 74.4%
  4 0.7695196310752579 77.0%
  5 0.722992322198231 72.3%
  6 0.6328998169613341 63.3%
  7 0.47700767567418384 47.7%
  8 0.20535964630072892 20.5%
  Total: 0.6362506471427329 63.6%

  CPU schedulers
  --------------------
  9 0.0 0.0%
  10 0.19029540649365134 19.0%
  11 0.14385452115609224 14.4%
  12 0.21933603349409908 21.9%
  13 0.35848297174203697 35.8%
  14 0.14738875118256198 14.7%
  15 0.3639794423533703 36.4%
  16 0.44773559729274653 44.8%
  Total: 0.23388409046431985 23.4%

  IO schedulers
  --------------------
  17 0.0 0.0%
  18 0.0 0.0%
  19 0.0 0.0%
  20 0.0 0.0%
  21 0.0 0.0%
  22 0.022088642946234964 2.2%
  23 0.0 0.0%
  24 0.005435451752308079 0.5%
  25 0.0 0.0%
  26 0.0 0.0%
  Total: 0.0027524094698543043 0.3%

  Weighted
  --------------------
  0.8701335342826982 87.0%


  Reductions
  --------------------
  5646802667

  Context Switches
  --------------------
  1432933

  ================
  NEW MEASUREMENTS
  ================

  Normal schedulers
  --------------------
  1 0.7678226385436394 76.8%  -0.02799434948295676 -3.517587939698487%
  2 0.789557175826906 79.0%  0.04679238864583035 6.325706594885602%
  3 0.7426595896512281 74.3%  -9.847200732288064e-4 -0.1344086021505433%
  4 0.7287875343721356 72.9%  -0.04073209670312228 -5.324675324675326%
  5 0.7251303712456584 72.5%  0.002138049047427426 0.2766251728907321%
  6 0.654483247545952 65.4%  0.02158343058461787 3.3175355450237163%
  7 0.5260909805272564 52.6%  0.04908330485307261 10.272536687631018%
  8 0.1744537465128909 17.4%  -0.03090589978783803 -15.121951219512198%
  Total: 0.6386231605282083 63.9%  0.0023725133854753944 0.47169811320755173%

  CPU schedulers
  --------------------
  9 0.0 0.0%  0.0 0%
  10 0.08239264907060809 8.2%  -0.10790275742304326 -56.8421052631579%
  11 0.3554343972801316 35.5%  0.21157987612403936 146.52777777777777%
  12 0.2309958826942838 23.1%  0.01165984920018473 5.479452054794535%
  13 0.28517744709864123 28.5%  -0.07330552464339574 -20.391061452513952%
  14 0.2605821673583168 26.1%  0.11319341617575482 77.55102040816328%
  15 0.3547578394069964 35.5%  -0.009221602946373919 -2.47252747252746%
  16 0.1718379980651045 17.2%  -0.275897599227642 -61.607142857142854%
  Total: 0.2176472976217603 21.8%  -0.01623679284255955 -6.8376068376068275%

  IO schedulers
  --------------------
  17 0.0 0.0%  0.0 0%
  18 0.0 0.0%  0.0 0%
  19 0.0 0.0%  0.0 0%
  20 0.016376935901930366 1.6%  0.016376935901930366 nan
  21 0.023006676536450974 2.3%  0.023006676536450974 nan
  22 0.0 0.0%  -0.022088642946234964 -100%
  23 0.0 0.0%  0.0 0%
  24 0.0 0.0%  -0.005435451752308079 -100%
  25 0.0 0.0%  0.0 0%
  26 0.0 0.0%  0.0 0%
  Total: 0.003938361243838134 0.4%  0.00118595177398383 33.33333333333334%

  Weighted
  --------------------
  0.8562689662714587 85.6%  -0.013864568011239586 -1.6091954022988517%


  Reductions
  --------------------
  5632182278  -14620389 -0.25891446650760486%

  Context Switches
  --------------------
  1428378  -4555 -0.31787948215303174%
  ```

* `Beamchmark.Formatters.HTML`

  The HTML formatter will save the report to an HTML file.
  
  ![Screenshot of an HTML report](https://user-images.githubusercontent.com/31112335/157873900-3ebc0e95-76ab-4d42-b40f-464d5681eb94.png)

* Custom formatters

  You can implement your custom formatters by overriding `Beamchmark.Formatter` behaviour.

## Copyright and License
Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
