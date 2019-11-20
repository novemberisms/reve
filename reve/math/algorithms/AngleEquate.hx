package reve.math.algorithms;

class AngleEquate {

    private static final TAU = 2 * Math.PI;

    public static function angleEquals(angleA: Float, angleB: Float, epsilon = 0.001): Bool {

        while (angleA < 0) angleA += TAU;
        while (angleB < 0) angleB += TAU;

        while (angleA >= TAU) angleA -= TAU;
        while (angleB >= TAU) angleB -= TAU;

        final diff = angleA - angleB;

        return Math.abs(diff) < epsilon;
    }
}