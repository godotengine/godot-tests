The current GDScript unit testing framework does not support using global class names loaded from other files. This test contains a scenario in which that is necessary in order to test for cyclic dependencies in the compilation stage of GDScripts.

This project contains a main scene with a script which forces a very specific order of loading of a cyclic dependency. The cyclic dependency consists of three classes, named `Daughter`, `Mother`, and `Grandmother` with the following connections: `Daughter extends Mother extends Grandmother`. However, `Grandmother uses Daughter`, forming a cyclic dependency including both inheritance as well as mere usage.

The first class loaded is `Mother`, which requires resolving `Grandmother`, which requires resolving `Daughter`. How much each class is resolved, and when, is crucial to successful compilation of this script.

Note: once the unit testing framework supports registering and using global class names from different script files, this test can be moved there.