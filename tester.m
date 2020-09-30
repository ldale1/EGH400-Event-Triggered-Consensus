% Cleanup
clc; close all; clear all;

%%
import ConsensusMAS.*;
import ConsensusMAS.Utils.*

import matlab.unittest.selectors.HasParameter

suite = matlab.unittest.TestSuite.fromClass(?ConsensusMAS.TestRand)
selector = HasParameter('property', 'implementations', 'Name', 'FixedTrigger');
suite.selectIf(selector).run;
