package reve.fsm;

@:generic
class FiniteStateMachine<State: EnumValue, Activation: EnumValue> {
    
    public var state(default, null): State;

    private final _stateMap: FsmStateMap<State, Activation>;

    public function new(initialState: State, stateMap: FsmStateMap<State, Activation>) {
        state = initialState;
        _stateMap = stateMap;
    }

    public function send(activation: Activation) {
        state = _stateMap.getDestination(state, activation);
    }
}

@:generic
class FsmStateMap<State: EnumValue, Activation: EnumValue> {

    /** Each state with transitions is a Key in this map. The value is a map of each 
        possible activation pointing to its destination state. **/
    private final _transitionsPerState: Map<State, Map<Activation, State>>;

    private final _globalTransitions: Map<Activation, State> = [];

    public function new(transitionsPerState: Map<State, Map<Activation, State>>) {
        _transitionsPerState = transitionsPerState;
    }

    public inline function globalTransition(activation: Activation, destination: State) {
        _globalTransitions[activation] = destination;
    }

    @:noCompletion
    public function getDestination(source: State, activation: Activation): State {
        // check for global activations first
        if (_globalTransitions.exists(activation)) return _globalTransitions[activation];

        // then check for single transitions
        // if the state has no defined transitions at all, then stay in the same state no matter what
        if (!_transitionsPerState.exists(source)) return source;

        // the state does have a few defined transition edges
        final transitions = _transitionsPerState[source];

        // but if the activation is not what triggers any of them, then stay in the same place
        if (!transitions.exists(activation)) return source;

        // this means the activation does go to another state, so return the destination
        return transitions[activation];
    }
}
