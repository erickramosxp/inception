<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', $_ENV['WORDPRESS_DB_NAME'] ?? 'wordpress' );

/** Database username */
define( 'DB_USER', $_ENV['WORDPRESS_DB_USER'] ?? 'wordpress' );

/** Database password */
define( 'DB_PASSWORD', $_ENV['WORDPRESS_DB_PASSWORD'] ?? 'password' );

/** Database hostname */
define( 'DB_HOST', $_ENV['WORDPRESS_DB_HOST'] ?? 'localhost');

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

define('AUTH_KEY',         'fbs[>D;7ad +GD//:JV[b)tvVFeyMULBPhPeU5OpH+k[D@08/ssB6wg>Z$RWOj]R');
define('SECURE_AUTH_KEY',  'wA=P$D@Lg-.!$3P%/RT0{|T]PeGpByBA*AAC;aPdSE[VukxB-Z+HB$))KJ1%py~p');
define('LOGGED_IN_KEY',    'zsM-nm=Akw.>G]`0c&.@lpOdl_aAk`-O&e}ZFH4ma{~$:zTZIn[xQ3u?s&&7^YJN');
define('NONCE_KEY',        '`e~vM3=K(9P<A?]2Q*j`;&V<oX|jS&KVLR :Ju{D+edQ.$xB-~4.n)zFyN]3tA|)');
define('AUTH_SALT',        '|Y_+mzmw_DdIqM=4%VBPKKKrU:-CCC+S +-2D-:?dhi^-]kw+`T+#nm6GBRgSKQ^');
define('SECURE_AUTH_SALT', 'be#KpnEt-L?HxG)=r-;Dq%0zYn9{r8VL |82;O9ZHAjt**uAvZtVXX|A=>UUY))A');
define('LOGGED_IN_SALT',   'Al!?+eKtNUts+dL88yMQ$o4~b(u^ELbn%h:M}O9DjYtL^ Q#l7q2zcaCR9Yf06M/');
define('NONCE_SALT',       'F_:^s 7j,r2#wokS4s0)x+i[q^?%B,l~d$-xAg5N+?c{OzdT{5O],6mYVPA[#sob');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
