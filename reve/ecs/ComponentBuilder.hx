package reve.ecs;

// Some of these appear unused, but they are all actually used.
// The linter just can't detect if it's being used 
// within the macro public static function build
import haxe.macro.Context;
import haxe.macro.Expr;
using reve.util.StringUtils;
using haxe.macro.TypeTools;
using Lambda;

/** 
    This is required for all Components. 

    It takes a component definition like this:

    ```haxe
    class Position extends Component {
        public var position: Vector = Vector.zero;
        @:event public var layer: Int = 0;
    }
    ```

    and adds all necessary overrides, methods, and some helper static extension methods
    to turn it into this:

    ```haxe
    class Position extends Component {
        // original fields
        public var position: Vector = Vector.zero;
        @:event public var layer: Int = 0;

        // generated fields

        // for component identification
        public static inline final id: engine.ecs.Component.ComponentID = "Position";
        
        public inline override function getComponentID(): engine.ecs.Component.ComponentID {
            return id;
        }

        // for position
        public static inline function getPosition(e: Entity): Vector {
            final component: Position = e.getComponent("Position");
            return component.position;
        }

        public static inline function setPosition(e: Entity, value: Vector): Void {
            final component: Position = e.getComponent("Position");
            component.position = value;
        }

        // for layer

        private final layerEvent: engine.util.Event<Int> = new engine.util.Event();

        public static inline function getLayer(e: Entity): Int {
            final component: Position = e.getComponent("Position");
            return component.layer;
        }

        public static inline function setLayer(e: Entity, value: Int): Void {
            final component: Position = e.getComponent("Position");
            component.layerEvent.execute(value);
            component.layer = value;
        }

        public static inline function getLayerEvent(e: Entity): engine.util.Event<Int> {
            final component: Position = e.getComponent("Position");
            return component.layerEvent;
        }

        // for event initialization

        public override inline function triggerEventsWithInitialValues(): Void {
            layerEvent.execute(layer);
        }

    }
    ```
**/
class ComponentBuilder {
    macro public static function build(): Array<Field> {
        // the "macro" keyword allows this method to be used as a build macro
        // and gives haxe.macro.Context access to most of its own methods.
        // This function is called with @:build(engine.ecs.ComponentBuilder.build())
        
        final fields = Context.getBuildFields();
        final classPath = Context.getLocalClass().toString().split(".");
        final className = classPath[classPath.length - 1];

        // the component id
        final id = macro $v{className};

        final classType = Context.getLocalType().toComplexType();

        // generate a field like
        // public static inline final id = "Position";
        fields.push(generateIdField(id, Context.currentPos()));

        // generate a field like
        // public inline override function getComponentID() return id;
        fields.push(generateGetComponentIDMethod(Context.currentPos()));

        // generate auto getters and setters, and the event fields if they are marked as @:event

        // doing this to avoid potential infinite loops where we generate fields for fields that 
        // have been generated, and then generate more fields for those generated fields, etc.
        final fieldsToGenerate: Array<Field> = [];
        final eventsGenerated: Map<String, String> = [];

        // which fields actually need autogetters and setters generated for them?
        for (field in fields) {
            switch field.kind {
            case FieldType.FFun(_): 
                // remember that switch expressions do not fall through in haxe
                // so this continue actually continues the outer for loop
                continue;
            default:
                // don't generate auto getter and auto setter for private and static vars
                if (field.access.has(AStatic) || field.access.has(APrivate)) continue;
                fieldsToGenerate.push(field); 
            }
        }

        for (field in fieldsToGenerate) {

            // we have to pass in Context.currentPos because the helper
            // function is not marked as a macro, and thus Context will
            // not be able to call currentPos() inside it
            fields.push(generateAutoGetter(
                field, 
                classType, 
                id,
                Context.currentPos() 
            ));

            if (isEvent(field)) {
                fields.push(generateEvent(field, Context.currentPos()));
                fields.push(generateEventGetter(
                    field, 
                    classType, 
                    id, 
                    Context.currentPos()
                ));
                fields.push(generateAutoSetterWithEvent(
                    field,
                    classType,
                    id,
                    Context.currentPos()
                ));
                eventsGenerated[nameEvent(field)] = field.name;
            } else {
                fields.push(generateAutoSetter(
                    field,
                    classType,
                    id,
                    Context.currentPos()
                ));
            }

        }

        fields.push(generateTriggerEventsWithInitialValues(eventsGenerated, Context.currentPos()));

        return fields;
    }

    //=========================================================================

    private static function generateIdField(componentIdExpr: Expr, position: Position): Field {
        return {
            name: "id",
            doc: "Static identifier used for this component",
            meta: [],
            access: [APublic, AStatic, AInline, AFinal],
            kind: FVar(macro : engine.ecs.Component.ComponentID, componentIdExpr),
            pos: position,
        };
    }

    private static function generateGetComponentIDMethod(position: Position): Field {
        final functionBody: Function = {
            args: [],
            ret: macro : engine.ecs.Component.ComponentID,
            expr: macro return id,
        };
        
        return {
            name: "getComponentID",
            doc: "gets the unique component id for this component",
            meta: [],
            access: [APublic, AOverride, AInline],
            kind: FFun(functionBody),
            pos: position,  
        };
    }

    /**
        For the Position component with a field called `position` of type `Vector`, 
        Generates the following:

        ```haxe
        public static inline function getPosition(e: Entity): Vector {
            final component: Position = e.getComponent("Position");
            return component.position;
        }
        ```
    **/
    private static function generateAutoGetter(field: Field, componentType: ComplexType, componentIdExpr: Expr, position: Position): Field {
        final fieldName = field.name;
        final fieldType = getFieldType(field);

        final getComponentStmt
            = macro final component: $componentType = e.getComponent($componentIdExpr);
        final returnStmt 
            = macro return component.$fieldName;

        final functionBody: Function = {
            args: [{name: "e", type: macro : engine.ecs.Entity}],
            ret: macro : $fieldType, 
            expr: macro $b{[
                getComponentStmt,
                returnStmt,
            ]}
        };

        final getter: Field = {
            name: nameAutoGetter(field),
            pos: position,
            doc: null,
            meta: [],
            access: [APublic, AStatic, AInline],
            kind: FFun(functionBody),
        };

        return getter;
    }

    /**
        For the Position component with a field called `position` of type `Vector`, 
        Generates the following:

        ```haxe
        public static inline function setPosition(e: Entity, value: Vector): Void {
            final component: Position = e.getComponent("Position");
            component.position = value;
        }
        ```
    **/
    private static function generateAutoSetter(field: Field, componentType: ComplexType, componentIdExpr: Expr, position: Position): Field {
        final fieldName = field.name;
        final fieldType = getFieldType(field);

        final getComponentStmt
            = macro final component: $componentType = e.getComponent($componentIdExpr);
        final setStmt 
            = macro component.$fieldName = value;

        final functionBody: Function = {
            args: [
                {name: "e", type: macro : engine.ecs.Entity},
                {name: "value", type: fieldType}
            ],
            ret: macro : Void,
            expr: macro $b{[
                getComponentStmt,
                setStmt,
            ]}
        }

        final setter: Field = {
            name: nameAutoSetter(field),
            pos: position,
            doc: null,
            meta: [],
            access: [APublic, AStatic, AInline],
            kind: FFun(functionBody),
        };

        return setter;
    }


    /**
        For the Position component with a field called `position` of type `Vector`, annotated with `@:event`,
        Generates the following:

        ```haxe
        public static inline function setPosition(e: Entity, value: Vector): Void {
            final component: Position = e.getComponent("Position");
            component.positionEvent.execute(value);
            component.position = value;
        }
        ```
    **/
    private static function generateAutoSetterWithEvent(field: Field, componentType: ComplexType, componentIdExpr: Expr, position: Position): Field {
        final fieldName = field.name;
        final fieldType = getFieldType(field);
        final eventName = nameEvent(field);

        final getComponentStmt
            = macro final component: $componentType = e.getComponent($componentIdExpr);
        final executeEventStmt
            = macro component.$eventName.execute(value);
        final setStmt 
            = macro component.$fieldName = value;


        final functionBody: Function = {
            args: [
                {name: "e", type: macro : engine.ecs.Entity},
                {name: "value", type: fieldType},
            ],
            ret: macro : Void,
            expr: macro $b{[
                getComponentStmt,
                executeEventStmt,
                setStmt,
            ]}
        };


        final setter: Field = {
            name: nameAutoSetter(field),
            pos: position,
            doc: null,
            meta: [],
            access: [APublic, AStatic, AInline],
            kind: FFun(functionBody),
        };

        return setter;
    }

    private static function generateEvent(field: Field, position: Position): Field {
        final fieldType = getFieldType(field);

        return {
            name: nameEvent(field),
            doc: "Event that triggers when " + field.name + " is changed",
            meta: [],
            access: [APrivate, AFinal],
            kind: FVar(macro : engine.util.Event<$fieldType>, macro new engine.util.Event()),
            pos: position,
        };
    }

    /**
        For the Position component with a field called `position` of type `Vector`, annotated with `@:event`,
        Generates the following:

        ```haxe
        public static inline function getPositionEvent(e: Entity): Event<Vector> {
            final component: Position = e.getComponent("Position");
            return component.positionEvent;
        }
        ```
    **/
    private static function generateEventGetter(field: Field, componentType: ComplexType, componentIdExpr: Expr, position: Position): Field {
        final eventFieldName = nameEvent(field);
        final fieldType = getFieldType(field);

        final getComponentStmt
            = macro final component: $componentType = e.getComponent($componentIdExpr);
        final returnStmt
            = macro return component.$eventFieldName;

        final functionBody: Function = {
            args: [
                {name: "e", type: macro : engine.ecs.Entity},
            ],
            ret: macro : engine.util.Event<$fieldType>,
            expr: macro $b{[
                getComponentStmt,
                returnStmt,
            ]}
        };

        final getter: Field = {
            name: nameEventGetter(field),
            pos: position,
            doc: null,
            meta: [],
            access: [APublic, AStatic, AInline],
            kind: FFun(functionBody),
        };

        return getter;
    }

    private static function generateTriggerEventsWithInitialValues(events: Map<String, String>, position: Position): Field {

        final lines = [
            for (eventname => fieldname in events) macro $i{eventname}.execute($i{fieldname})
        ];
        
        final functionBody: Function = {
            args: [],
            ret: macro : Void,
            expr: macro $b{lines}
        };
        
        final result: Field = {
            name: "triggerEventsWithInitialValues",
            pos: position,
            doc: null,
            meta: [],
            access: [APublic, AOverride, AInline],
            kind: FFun(functionBody),
        };

        return result;
    }


    //=========================================================================

    private static function getFieldType(field: Field): ComplexType {
        switch field.kind {
        case FieldType.FVar(type, _):
            return type;
        case FieldType.FProp(_, _, type, _):
            return type;
        case FieldType.FFun(f):
            return f.ret;
        }
    }

    private static function isEvent(field: Field): Bool {
        if (field.meta == null) return false;
        return field.meta.exists(m -> m.name == ":event");
    }

    /** position -> getPosition **/
    private static function nameAutoGetter(field: Field): String {
        return "get" + field.name.capitalizeFirst();
    }

    /** position -> setPosition **/
    private static function nameAutoSetter(field: Field): String {
        return "set" + field.name.capitalizeFirst();
    }

    /** position -> positionEvent **/
    private static function nameEvent(field: Field): String {
        return field.name + "Event";
    }

    /** position -> getPositionEvent **/
    private static function nameEventGetter(field: Field): String {
        return "get" + nameEvent(field).capitalizeFirst();
    }
}