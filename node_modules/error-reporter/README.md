# Error Reporter [![Build Status](https://travis-ci.org/gss/error-reporter.png?branch=master)](https://travis-ci.org/gss/error-reporter)
Provide source code context when reporting errors.

```
Error on line 9, column 30: Invalid strength or weight

 8 : #box1[width] == #box2[width] !strong;
 9 : #box3[width] == #box4[width] !stron;
 ^ : -----------------------------^
10 : #box5[width] == #box6[width] !strong;
```
