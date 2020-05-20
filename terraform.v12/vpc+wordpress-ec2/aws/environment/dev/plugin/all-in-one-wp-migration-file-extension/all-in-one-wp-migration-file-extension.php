<?php
/**
 * Plugin Name: All-in-One WP Migration File Extension
 * Plugin URI: https://import.wp-migration.com/
 * Description: Extension for All in One WP Migration that enables using import from file
 * Author: ServMask, Inc.
 * Author URI: https://servmask.com/
 * Version: 1.5
 * Text Domain: all-in-one-wp-migration-file-extension
 * Domain Path: /languages
 * Network: True
 *
 * Copyright (C) 2014-2019 ServMask Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ███████╗███████╗██████╗ ██╗   ██╗███╗   ███╗ █████╗ ███████╗██╗  ██╗
 * ██╔════╝██╔════╝██╔══██╗██║   ██║████╗ ████║██╔══██╗██╔════╝██║ ██╔╝
 * ███████╗█████╗  ██████╔╝██║   ██║██╔████╔██║███████║███████╗█████╔╝
 * ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║╚██╔╝██║██╔══██║╚════██║██╔═██╗
 * ███████║███████╗██║  ██║ ╚████╔╝ ██║ ╚═╝ ██║██║  ██║███████║██║  ██╗
 * ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
 */

if ( ! defined( 'ABSPATH' ) ) {
	die( 'Kangaroos cannot jump here' );
}

define( 'AI1WMTE_PLUGIN_BASENAME', basename( dirname( __FILE__ ) ) . '/' . basename( __FILE__ ) );

define( 'AI1WMTE_PATH', dirname( __FILE__ ) );

define( 'AI1WMTE_URL', plugins_url( '', AI1WMTE_PLUGIN_BASENAME ) );

require_once dirname( __FILE__ ) . DIRECTORY_SEPARATOR . 'constants.php';
require_once dirname( __FILE__ ) . DIRECTORY_SEPARATOR . 'loader.php';

$main_controller = new Ai1wmte_Main_Controller();
