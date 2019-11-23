package reve.collision;

abstract CollisionShapeOwnerID(Int) {

	public static var currentID = 0;

	public static function iota(): CollisionShapeOwnerID {
		currentID += 1;
		return new CollisionShapeOwnerID(currentID);
	}

	public function new(from:Int) {
		this = from;
	}
}