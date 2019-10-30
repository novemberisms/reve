package reve.ecs;
/**

    When creating new systems, you should think about where the system should fit in the
    execution order and decide based on its data dependencies.

**/


//=============================================================================
// MAIN PHASE CATEGORIES
// These are the four broadest system phase categories. The next enum abstracts
// list the subphases within each of these
//=============================================================================
enum abstract SystemPhase(String) to String {
    /** Receive input from the player or from an AI **/
    var input;
    /** Modify internal state based on input. **/
    var control;
    /** Perform deterministic calculations to evolve internal state. **/
    var physics;
    /** Modify graphical representation of data **/
    var display;
}

//=============================================================================
enum abstract InputPhase(String) to String {
    /** Receive input from the keyboard or gamepad. **/
    var playerInput;
    /** Receive input from an AI **/
    var aiInput;
}

//=============================================================================
enum abstract ControlPhase(String) to String {
    /** Update all the action controllers and dispatch the events **/
    var dispatchActions;
}
//=============================================================================
enum abstract PhysicsPhase(String) to String {
    /** Modify position **/
    var velocity;
    /** Detect all occuring collisions and react to them. The reactions can modify 
        physical properties and internal state. After reacting, detect all collisions again
        and repeat the process until reaching a stable state or an iteration cap is reached. **/
    var collision;
}

//=============================================================================
enum abstract DisplayPhase(String) to String {
    /** Update, pause, or switch sprites if they are animations **/
    var animation;
    /** Apply local transformations to the camera. **/
    var camera;
    /** Apply local transformations to the sprites. This is the last**/
    var present;
}