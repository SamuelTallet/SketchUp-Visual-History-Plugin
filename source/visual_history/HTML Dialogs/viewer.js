/**
 * Visual History (VHY) Viewer.
 *
 * @package VHY extension for SketchUp
 *
 * @copyright © 2020 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * Visual History plugin namespace.
 */
VisualHistory = {}

/**
 * Listens to "thumbnail" image click.
 */
VisualHistory.listenToThumbnailImages = () => {

	let thumbnailImages = document.querySelectorAll('.visual-history-thumbnail')

	thumbnailImages.forEach(thumbnailImage => {

		thumbnailImage.addEventListener('click', event => {

			sketchup.goBackToState(event.currentTarget.dataset.stateIndex)

		})

	})

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

	window.setTimeout(() => {

		// Scrolls down... Displays latest thumbnail.
		window.scrollTo(0, document.body.scrollHeight)

	}, 300)

	VisualHistory.listenToThumbnailImages()

})
