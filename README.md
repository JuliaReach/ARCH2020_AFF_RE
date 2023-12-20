# ARCH2020 AFF

This is the JuliaReach repeatability evaluation (RE) package for the ARCH-COMP
2020 category report: Continuous and Hybrid Systems with Linear Continuous
Dynamics of the 4th International Competition on Verifying Continuous and Hybrid
Systems (ARCH-COMP '20).

To cite the work, you can use:

```
@inproceedings{AlthoffBBFFFKLM20,
  author    = {Matthias Althoff and
               Stanley Bak and
               Zongnan Bao and
               Marcelo Forets and
               Goran Frehse and
               Daniel Freire and
               Niklas Kochdumper and
               Yangge Li and
               Sayan Mitra and
               Rajarshi Ray and
               Christian Schilling and
               Stefan Schupp and
               Mark Wetzlinger},
  editor    = {Goran Frehse and
               Matthias Althoff},
  title     = {{ARCH-COMP20} Category Report: Continuous and Hybrid Systems with
               Linear Continuous Dynamics},
  booktitle = {{ARCH}},
  series    = {EPiC Series in Computing},
  volume    = {74},
  pages     = {16--48},
  publisher = {EasyChair},
  year      = {2020},
  url       = {https://doi.org/10.29007/7dt2},
  doi       = {10.29007/7dt2}
}
```

## Installation

There are two ways to install and run this RE: either using the Julia script,
or using the included Dockerfile. In both cases, first clone this repository:

```shell
$ git clone https://github.com/JuliaReach/ARCH2020_AFF_RE.git
$ cd ARCH2020_AFF_RE
```

**Using the Julia script.** First install the Julia language in your system following
the instructions in the [Downloads page](http://julialang.org/downloads). Once
you have installed Julia installed in your system, do

```shell
$ julia startup.jl
```
to run all the benchmarks. Afer this command has finished, the results will be stored
under the folder `result/results.csv` and the generated plots in your working directory.

**Using the Docker container.** To build the container, you need the program `docker`.
For installation instructions on different platforms, consult
[the Docker documentation](https://docs.docker.com/install/).
For general information about `Docker`, see
[this guide](https://docs.docker.com/get-started/).
Once you have installed Docker, start the `measure_all` script:
script:

```shell
$ measure_all
```
The output results will be saved under the folder `result/`,
and the generated plots will be in your working directory.

---

The Docker container can also be run interactively.
To run it interactively, type:

```shell
$ docker run -it juliareach bash

$ julia

julia> include("startup.jl")
```

---

The file `startup.jl` contains a flag `TEST_LONG` (default: `false`) that can be
used to select to run or not the longer instances, such as the HEAT04 model that
may take ~ 1 hour.

## About this RE

This repeatability evaluation package relies on Julia's package manager, `Pkg`, to create an environment that can be used to exactly use the same package versions in different machines. For further instructions on creating this RE, see [this wiki](https://github.com/JuliaReach/ARCH2020_NLN_RE/wiki/Instructions-for-creating-this-RE).
