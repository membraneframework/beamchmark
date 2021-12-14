# Beamchmark
[![Hex.pm](https://img.shields.io/hexpm/v/beamchmark.svg)](https://hex.pm/packages/beamchmark)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/beamchmark)
[![CircleCI](https://circleci.com/gh/membraneframework/beamchmark.svg?style=svg)](https://circleci.com/gh/membraneframework/beamchmark)

Tool for measuring EVM performance.

At the moment, the main interest of Beamchmark is scheduler utilization, reductions and context switches number.
For more information please refer to API docs.

## Beamchmark and Benchee
Beamchmark should be used when you want to measure BEAM performance while it is runing your application.
Benchee should be used when you want to benchmark specific function from your code base.
In particular, Benchee will inform you how long your function is executing while Beamchmark will inform you
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
To run example type: 

```bash
mix run examples/<example_name>.exs
```

### Example output

```txt
> mix run examples/advanced.exs

Running scenario
Waiting 1 seconds
Benchmarking

================
SYSTEM INFO
================

System version: Erlang/OTP 24 [erts-12.0.3] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]
System arch: x86_64-pc-linux-gnu
NIF version: 2.16

================
BASE
================

Normal schedulers
--------------------
1 1.0668080386966647e-4 0.0%
2 7.998836416749597e-5 0.0%
3 4.2106493950736044e-4 0.0%
4 3.639672738461754e-7 0.0%
5 4.7350414264111834e-4 0.0%
6 0.0043860455491825795 0.4%
7 8.102830226995653e-5 0.0%
8 1.6912821965950098e-4 0.0%
Total: 7.147255360714405e-4 0.1%

CPU schedulers
--------------------
9 0.0 0.0%
10 0.0 0.0%
11 0.0 0.0%
12 0.0 0.0%
13 0.0 0.0%
14 0.0 0.0%
15 0.0 0.0%
16 0.006471963981908292 0.6%
Total: 8.089954977385365e-4 0.1%

IO schedulers
--------------------

Total: 0 0%

Weighted
--------------------
0.001523719527435532 0.2%

Reductions
--------------------
11661549

Context Switches
--------------------
30602

================
NEW
================

Normal schedulers
--------------------
1 3.089102038763749e-4 0.0%  2.0222940000670843e-4 0%
2 3.782341555965018e-4 0.0%  2.982457914290058e-4 0%
3 3.6955770413050143e-6 0.0%  -4.1736936246605544e-4 0%
4 1.6818640195259216e-4 0.0%  1.67822434678746e-4 0%
5 3.98059971168814e-4 0.0%  -7.544417147230432e-5 0%
6 2.6124825293454316e-4 0.0%  -0.004124797296248036 -100%
7 0.005979264520280537 0.6%  0.00589823621801058 nan
8 1.3163673613384656e-4 0.0%  -3.749148352565442e-5 0%
Total: 9.536544773730643e-4 0.1%  2.389289413016238e-4 0%

CPU schedulers
--------------------
9 0.0 0.0%  0.0 0%
10 0.0 0.0%  0.0 0%
11 0.0 0.0%  0.0 0%
12 0.0 0.0%  0.0 0%
13 0.0 0.0%  0.0 0%
14 0.0 0.0%  0.0 0%
15 0.0 0.0%  0.0 0%
16 0.005779059586476821 0.6%  -6.929043954314717e-4 0%
Total: 7.223824483096026e-4 0.1%  -8.661304942893396e-5 0%

IO schedulers
--------------------

Total: 0 0%  0 0%

Weighted
--------------------
0.0016760349343240095 0.2%  1.5231540688847743e-4 0%

Reductions
--------------------
23727211  12065662 103.46534581297905%

Context Switches
--------------------
38717  8115 26.517874648715775%

Results successfully saved to "/tmp/beamchmark_output/new" directory
```

## Copyright and License

Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
