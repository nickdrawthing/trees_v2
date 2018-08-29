# trees_v2
Generates silly looking trees

This pde file can be run using Processing 3.0. It generates silly looking trees which animate (note that more complex trees will reduce framerate).

The basic principle governing these trees is that every branch of the tree contains an array of child branches. These nested arrays create the form of the tree.

The nested branch structure is contained within a tree class object which governs the generation rules. These rules inform the shape and number of branches, the number of iterations, and the parameters of the animation.

To create different looking trees, try adjusting the values in the tree class.
