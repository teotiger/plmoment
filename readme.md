# PLMoment

## Introduction
PLMoment is an implementation in PL/SQL for the Oracle Database to calculate the four [(mathematic) moments](https://en.wikipedia.org/wiki/Moment_(mathematics)) mean, variance (this includes standard deviation), skewness and kurtosis. It consists of a [User-Defined Aggregate Function](https://docs.oracle.com/database/122/ADOBJ/user-defined-aggregate-functions.htm#ADOBJ00607) and the necessary object types. It supports the windowing clause and [parallel query](https://docs.oracle.com/database/122/VLDBG/parallel-exec-intro.htm#VLDBG1377) via the parallel hint in SQL.

## Installation
Simply run the install script inside SQL*Plus.

## License
PLMoment is released under the [MIT license](https://github.com/teotiger/plutil/blob/master/license.txt).

## Compatibility
| PLMoment      | Oracle      | Excel (en)| Excel (de) |
| ------------- |-------------| ----------|------------|
| mean          | AVG         | AVERAGE   | MITTELWERT |
| variance_p    | VAR_POP     | VAR.P     | VAR.P      |
| variance_s    | VAR_SAMP    | VAR.S     | VAR.S      |
| stddev_p      | STDDEV_POP  | STDEV.P   | STABW.S    |
| stddev_s      | STDDEV_SAMP | STDEV.S   | STABW.N    |
| skewness_p    |             | SKEW.P    | SCHIEFE.P  |
| skewness_s    |             | SKEW      | SCHIEFE    |
| kurtosis_p    |             |           |            |
| kurtosis_s    |             |           |            |
| excess_p      |             |           |            |
| excess_s      |             | KURT      | KURT       |

For Skewness and Kurtosis/Excess there is no direct function available in Oracle. Check [examples.sql](https://github.com/teotiger/plmoment/blob/master/test/examples.sql) for an example to calculate these ratios with two-pass/subselects.

## Credits
- https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
- https://www.thinkbrg.com/media/publication/720_McCrary_ImplementingAlgorithms_Whitepaper_20151119_WEB.pdf
- https://www.johndcook.com/blog/skewness_kurtosis/
- https://github.com/johnmyleswhite/StreamStats.jl/blob/master/src/moments.jl

## Version History
Version 0.3 – December 6, 2017
* Bugfixes in parallel query
* better code structure
* extended readme

Version 0.2 – November 13, 2017
* Parallel executing added

Version 0.1 – November 9, 2017
* Initial release
