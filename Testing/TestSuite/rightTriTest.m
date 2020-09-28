% test triangles

%{
In your working folder, create a new script, rightTriTest.m. Each unit test 
checks a different output of the rightTri function. A test script must 
adhere to the following conventions:
-The name of the script file must start or end with the word 'test', 
    which is case-insensitive.
-Place each unit test into a separate section of the script file. Each 
    section begins with two percent signs (%%), and the text that follows 
    on the same line becomes the name of the test element. If no text 
    follows the %%, MATLAB assigns a name to the test. If MATLAB encounters 
    a test failure, it still runs remaining tests.
-In a test script, the shared variable section consists of any code that 
    appears before the first explicit code section. Tests share the 
    variables that you define in this section. Within a test, you can 
    modify the values of these variables. However, in subsequent tests, the 
    value is reset to the value defined in the shared variables section.
-In the shared variables section (first code section), define any 
    preconditions necessary for your tests. If the inputs or outputs do not 
    meet this precondition, MATLAB does not run any of the tests. MATLAB 
    marks the tests as failed and incomplete.
-When a script is run as a test, variables defined in one test are not 
    accessible within other tests unless they are defined in the shared 
    variables section (first code section). Similarly, variables defined 
    in other workspaces are not accessible to the tests.
-If the script file does not include any code sections, MATLAB generates 
    a single test element from the full contents of the script file. The 
    name of the test element is the same as the script file name. In this 
    case, if MATLAB encounters a failed test, it halts execution of the 
    entire script.

Execute the runtests function to run the four tests in rightTriTest.m. 
The runtests function executes each test in each code section individually. 
If Test 1 fails, MATLAB still runs the remaining tests. If you execute 
rightTriTest as a script instead of by using runtests, MATLAB halts 
execution of the entire script if it encounters a failed assertion. 
Additionally, when you run tests using the runtests function, MATLAB 
provides informative test diagnostics.
%}

addpath("..");

% test triangles
tri = [7 9];
triIso = [4 4];
tri306090 = [2 2*sqrt(3)];
triSkewed = [1 1500];

% Define an absolute tolerance
tol = 1e-10; 
 
% preconditions
angles = rightTri(tri);
assert(angles(3) == 90,'Fundamental problem: rightTri not producing right triangle')

%% Test 1: sum of angles
angles = rightTri(tri);
assert(sum(angles) == 180)
 
angles = rightTri(triIso);
assert(sum(angles) == 180)
 
angles = rightTri(tri306090);
assert(sum(angles) == 180)
 
angles = rightTri(triSkewed);
assert(sum(angles) == 180)

%% Test 2: isosceles triangles
angles = rightTri(triIso);
assert(angles(1) == 45)
assert(angles(1) == angles(2))
 
%% Test 3: 30-60-90 triangle
angles = rightTri(tri306090);
assert(abs(angles(1)-30) <= tol)
assert(abs(angles(2)-60) <= tol)
assert(abs(angles(3)-90) <= tol)

%% Test 4: Small angle approximation
angles = rightTri(triSkewed);
smallAngle = (pi/180)*angles(1); % radians
approx = sin(smallAngle);
assert(abs(approx-smallAngle) <= tol, 'Problem with small angle approximation')