package reve.util;

class StringUtils {
    /** Capitalizes the first letter of the given string. **/
    public static function capitalizeFirst(s: String): String {
        final firstLetter = s.charAt(0);
        final rest = s.substr(1);
        return firstLetter.toUpperCase() + rest;
    }
}