//
//  ArtistList.swift
//  FlowPlayer
//

import SwiftUI

struct ArtistList: View {
	@StateObject var viewModel = ArtistListViewModel()
	@State private var showAlbumArtist = false

	var body: some View {
		List {
			if showAlbumArtist {
				ForEach(viewModel.albumArtistListRowViewModels) { albumArtistListRowViewModel in
					NavigationLink(destination: SongList(viewModel: .init(mediaItems: albumArtistListRowViewModel.mediaItemCollection.items, navigationTitle: albumArtistListRowViewModel.text))) {
						if let image = albumArtistListRowViewModel.image {
							SubtitleRowView(image: Image(uiImage: image), text: albumArtistListRowViewModel.text, secondaryText: albumArtistListRowViewModel.secondaryText)
						} else {
							SubtitleRowView(text: albumArtistListRowViewModel.text, secondaryText: albumArtistListRowViewModel.secondaryText)
						}
					}
				}
			} else {
				ForEach(viewModel.artistListRowViewModels) { artistListRowViewModel in
					NavigationLink(destination: SongList(viewModel: .init(mediaItems: artistListRowViewModel.mediaItemCollection.items, navigationTitle: artistListRowViewModel.text))) {
						if let image = artistListRowViewModel.image {
							SubtitleRowView(image: Image(uiImage: image), text: artistListRowViewModel.text, secondaryText: artistListRowViewModel.secondaryText)
						} else {
							SubtitleRowView(text: artistListRowViewModel.text, secondaryText: artistListRowViewModel.secondaryText)
						}
					}
				}
			}

		}.listStyle(PlainListStyle())
		.navigationTitle("아티스트")
		.navigationBarItems(trailing: toggleAlbumArtistButton)
	}
}

private extension ArtistList {
	var toggleAlbumArtistButton: some View {
		Button {
			showAlbumArtist.toggle()
		} label: {
			if showAlbumArtist {
				Image(systemName: "person.2.fill")
			} else {
				Image(systemName: "person.2")
			}
		}
	}
}
