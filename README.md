# Beamchmark
[![Hex.pm](https://img.shields.io/hexpm/v/beamchmark.svg)](https://hex.pm/packages/beamchmark)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/beamchmark)
[![CircleCI](https://circleci.com/gh/membraneframework/beamchmark.svg?style=svg)](https://circleci.com/gh/membraneframework/beamchmark)

Tool for measuring EVM performance.

At the moment, the main interest of Beamchmark is scheduler utilization, reductions and context switches number.
For more information please refer to API docs.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `beamchmark` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beamchmark, "~> 0.1.0"}
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
Benching

================
SYSTEM INFO
================

System version: Erlang/OTP 24 [erts-12.0] [source] [64-bit] [smp:6:6] [ds:6:6:10] [async-threads:1] [jit]
System arch: x86_64-pc-linux-gnu
NIF version: 2.16

================
BASE
================

Normal schedulers
--------------------
1 4.1363724142701014e-5 0.0%
2 6.698689960513343e-7 0.0%
3 4.522207798397024e-5 0.0%
4 0.0032032545868850215 0.3%
5 7.97951427426974e-6 0.0%
6 8.96313581421971e-5 0.0%
 
Total: 5.646868550707019e-4 0.1%


CPU schedulers
--------------------
7 0.0 0.0%
8 0.0 0.0%
9 0.0 0.0%
10 0.0 0.0%
11 0.0 0.0%
12 0.0035031965056329735 0.4%
 
Total: 5.838660842721622e-4 0.1%


IO schedulers
--------------------
 
Total: 0 0%


Weighted
--------------------
0.0011485509271607634 0.1%


================
NEW
================

Normal schedulers
--------------------
1 1.7995089166475283e-5 0.0%  -2.336863497622573e-5 0%
2 3.4187052703702885e-4 0.0%  3.412006580409775e-4 0%
3 0.0031852964551867696 0.3%  0.0031400743772027995 nan
4 3.4479323853181592e-6 0.0%  -0.0031998066544997035 -100%
5 4.0707008759676705e-6 0.0%  -3.908813398302069e-6 0%
6 9.237851367443481e-6 0.0%  -8.039350677475362e-5 0%
 
Total: 5.936530926698338e-4 0.1%  2.8966237599131945e-5 0%
 

CPU schedulers
--------------------
7 0.0 0.0%  0.0 0%
8 0.0 0.0%  0.0 0%
9 0.0 0.0%  0.0 0%
10 0.0 0.0%  0.0 0%
11 0.0 0.0%  0.0 0%
12 0.0036478619981375796 0.4%  1.446654925046061e-4 0%
 
Total: 6.079769996895966e-4 0.1%  2.4110915417434385e-5 0%


IO schedulers
--------------------
 
Total: 0 0%  0 0%


Weighted
--------------------
0.0012016268139945013 0.1%  5.307588683373782e-5 0%


Results successfully saved to "/tmp/beamchmark_output/new" directory
```

## Copyright and License

Copyright 2021, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=beamchmark)

Licensed under the [Apache License, Version 2.0](LICENSE)
