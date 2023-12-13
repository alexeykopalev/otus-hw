<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wp_db' );

/** Database username */
define( 'DB_USER', 'wp_user' );

/** Database password */
define( 'DB_PASSWORD', 'Db%@du8347Db' );

/** Database hostname */
define( 'DB_HOST', '10.10.1.4' );

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
define('AUTH_KEY',         'zE;k$65m*Z(r<p&3i4G,`&e?08s*S;KcBuI9&:>0j.lQjNOKmj$%~d+VWgA!E?2#');
define('SECURE_AUTH_KEY',  'q~eG?!} I7HF+$#w7msYm,HpSo(/jY@,P<wp>.I%us/r7+f^R+)<ZF}i=x$qwLm=');
define('LOGGED_IN_KEY',    '+J0k5xVI9aoHQ<>*I~5)b(uxB@a}70&(%EMedm|g^8|cd#@(+:zCKU^kH{B:|`Yf');
define('NONCE_KEY',        'w,Z$Bl|;XIYJKr4&G|M,W:^n_h6d?U@*C(H%EasCqXR?B}Sa-)}&Gjz};M:nx)0!');
define('AUTH_SALT',        'IIC~LCcrMgC6{@T%>&$PF[)qf<u:v3+D`o,i).qv0y/81V05z0Q_[-9sqlmF8sWo');
define('SECURE_AUTH_SALT', ' z/pj`bVlYT7CZIq!{J|.hJfhro3;Ec^++n?S)q8i{@qBn(Up8w^Wn3uyV2lHd$ ');
define('LOGGED_IN_SALT',   'cl)UJ[|sbD|-E*jR.CJikGl&W~./x,6i;a41:r>8#&kc{GzKFdaYb<ESYX.D-)-]');
define('NONCE_SALT',       '-3]Lw&?+<{WAc|]`oPN0s7*8m:_Pjl@t@$B(d~}]$U$5dV14e@0B-^Ub1ng>}zfO');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
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
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
