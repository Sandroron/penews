//
//  PaginatedListDataAdapter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import ObjectMapper

class PaginatedListDataAdapter<P: NoViewLoadingPresenter, T: Mappable, W: Wrapper<T>>: MultiPageListDataAdapter<P, PaginatedScreenPresenter, T, W> {
    
    // MARK: - Inits
    
    init(presenter: P, paginatedPresenter: PaginatedScreenPresenter, loadingState: LoadingState = .stub, loadingMoreState: LoadingMoreState = .loadMoreResult) {
        super.init(loadingPresenter: presenter, loadingMorePresenter: paginatedPresenter, loadingState: loadingState, loadingMoreState: loadingMoreState)
    }
}
