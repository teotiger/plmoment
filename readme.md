# PLMoment

## Introduction
PLMoment is an implementation in PL/SQL for the Oracle Database to calculate the four [(mathematic) moments](https://en.wikipedia.org/wiki/Moment_(mathematics)) mean, variance (this includes standard deviation), skewness and kurtosis. It consists of a [User-Defined Aggregate Function](https://docs.oracle.com/database/122/ADOBJ/user-defined-aggregate-functions.htm#ADOBJ00607) and the necessary object types. It supports the windowing clause and [parallel query](https://docs.oracle.com/database/122/VLDBG/parallel-exec-intro.htm#VLDBG1377) via the parallel hint in SQL.

## Installation
Simply run the install script inside SQL*Plus.

## License
PLMoment is released under the [MIT license](https://github.com/teotiger/plutil/blob/master/license.txt).

<!--
## Compatibility
excel dt. | excel eng. | ORacle | SPSS
bei oracle => avg(xxx)/power(stddev_samp(xx))

SKEW      https://support.office.com/en-us/article/SKEW-function-bdf49d86-b1ef-4804-a046-28eaea69c9fa
SKEW.P    https://support.office.com/en-us/article/SKEW-P-function-76530a5c-99b9-48a1-8392-26632d542fcb
KURT      https://support.office.com/en-us/article/KURT-function-bc3a265c-5da4-4dcb-b7fd-c237789095ab

## Credits
- wikipedia
- hedge Fund pdf
- https://www.johndcook.com/blog/skewness_kurtosis/
- https://github.com/johnmyleswhite/StreamStats.jl/blob/master/src/var.jl
-->

## Version History
Version 0.1 – November 9, 2017
* Initial release
