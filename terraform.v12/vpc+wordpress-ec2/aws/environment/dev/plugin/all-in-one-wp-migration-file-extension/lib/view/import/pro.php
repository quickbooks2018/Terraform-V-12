<?php
/**
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
?>

<?php _e( 'Maximum upload file size:', AI1WM_PLUGIN_NAME ); ?>
<?php if ( ( $max_file_size = apply_filters( 'ai1wm_max_file_size', AI1WM_MAX_FILE_SIZE ) ) ) : ?>
	<span class="ai1wm-max-upload-size"><?php echo ai1wm_size_format( $max_file_size ); ?></span>
	<span class="ai1wm-unlimited-import">
		<a href="https://servmask.com/products/unlimited-extension" target="_blank" class="ai1wm-label">
			<i class="ai1wm-icon-notification"></i>
			<?php _e( 'Get unlimited', AI1WM_PLUGIN_NAME ); ?>
		</a>
	</span>
<?php else : ?>
	<span class="ai1wm-max-upload-size"><?php _e( 'Unlimited', AI1WM_PLUGIN_NAME ); ?></span>
<?php endif; ?>
