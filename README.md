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
  1 0.726230562738185 72.6%
  2 0.690246339924378 69.0%
  3 0.7609273401563765 76.1%
  4 0.765306015657429 76.5%
  5 0.7214390798805188 72.1%
  6 0.6605425421288396 66.1%
  7 0.5077175285430668 50.8%
  8 0.1880211206504323 18.8%
  Total: 0.6275538162099032 62.8%

  CPU schedulers
  --------------------
  9 0.0 0.0%
  10 0.11333108957969748 11.3%
  11 0.30391882971249756 30.4%
  12 0.21847099731976113 21.8%
  13 0.04828720886376929 4.8%
  14 0.26259533609071634 26.3%
  15 0.2575963573107623 25.8%
  16 0.3358873831671351 33.6%
  Total: 0.1925109002555424 19.3%

  IO schedulers
  --------------------
  17 0.0 0.0%
  18 0.0 0.0%
  19 0.027955817191577047 2.8%
  20 0.0230406302017115 2.3%
  21 0.0 0.0%
  22 0.0 0.0%
  23 0.0 0.0%
  24 0.0 0.0%
  25 0.011817267012281014 1.2%
  26 0.0 0.0%
  Total: 0.0062813714405569555 0.6%

  Weighted
  --------------------
  0.8200651634043559 82.0%


  Reductions
  --------------------
  5620233975

  Context Switches
  --------------------
  1428421

  ================
  NEW MEASUREMENTS
  ================

  Normal schedulers
  --------------------
  1 0.7499019036753423 75.0%  0.02367134093715728 3.305785123966956%
  2 0.6899644901888539 69.0%  -2.818497355241423e-4 0%
  3 0.7123057662321732 71.2%  -0.0486215739242033 -6.4388961892246925%
  4 0.7737598710238 77.4%  0.008453855366371 1.1764705882353184%
  5 0.6692436512735784 66.9%  -0.052195428606940375 -7.212205270457687%
  6 0.6073236647989574 60.7%  -0.053218877329882175 -8.169440242057476%
  7 0.4953068058747823 49.5%  -0.012410722668284524 -2.559055118110237%
  8 0.24003727839702893 24.0%  0.052016157746596625 27.659574468085097%
  Total: 0.6172304289330646 61.7%  -0.01032338727683868 -1.751592356687894%

  CPU schedulers
  --------------------
  9 0.0 0.0%  0.0 0%
  10 0.28973086928273717 29.0%  0.1763997797030397 156.6371681415929%
  11 0.2112894290721681 21.1%  -0.09262940064032946 -30.59210526315789%
  12 0.14710206668727463 14.7%  -0.0713689306324865 -32.56880733944955%
  13 0.2757453546929915 27.6%  0.2274581458292222 475.0000000000001%
  14 0.0 0.0%  -0.26259533609071634 -100%
  15 0.4077499697013695 40.8%  0.1501536123906072 58.13953488372093%
  16 0.17050735973400669 17.1%  -0.16538002343312844 -49.10714285714286%
  Total: 0.18776563114631847 18.8%  -0.004745269109223932 -2.5906735751295287%

  IO schedulers
  --------------------
  17 0.0 0.0%  0.0 0%
  18 0.0 0.0%  0.0 0%
  19 0.0 0.0%  -0.027955817191577047 -100%
  20 0.0 0.0%  -0.0230406302017115 -100%
  21 0.0 0.0%  0.0 0%
  22 0.0 0.0%  0.0 0%
  23 0.023823627916997984 2.4%  0.023823627916997984 nan
  24 0.0 0.0%  0.0 0%
  25 0.016157181485821525 1.6%  0.004339914473540511 33.33333333333334%
  26 0.0 0.0%  0.0 0%
  Total: 0.003998080940281951 0.4%  -0.002283290500275005 -33.33333333333333%

  Weighted
  --------------------
  0.8049949532364773 80.5%  -0.015070210167878573 -1.8292682926829258%


  Reductions
  --------------------
  5618282674  -1951301 -0.03471921291318836%

  Context Switches
  --------------------
  1428312  -109 -0.007630803523611007%
  ```

* `Beamchmark.Formatters.HTML`

  The HTML formatter will save the report to an HTML file.
  
  ![Screenshot of an HTML report](https://user-images.githubusercontent.com/31112335/157427012-7cd01c7d-967e-4829-bf4c-a6511d4865fe.png)

* Custom formatters

  You can implement your custom formatters by overriding `Beamchmark.Formatter` behaviour.

## Copyright and License
Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
