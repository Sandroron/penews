//
//  MultiPageListDataAdapter.swift
//  penews
//
//  Created by Razumnyi Aleksandr on 25.03.2022.
//

import Alamofire
import ObjectMapper
import RxSwift

class MultiPageListDataAdapter<LP: NoViewLoadingPresenter, LMP: NoViewLoadingMorePresenter, T: Mappable, W: Wrapper<T>>: ReadDataAdapter<W>, PaginationViewDataProvider {
    
    // MARK: - Properties (Params)
    
    var key_count = "pageSize"      // The name of the query parameter responsible for the number of objects on the page
    var key_start = "page"          // The name of the query parameter responsible for the page number
    var countPagesInBlock = 3       // The number of pages in the pagination block
    var countObjectsOnPage = 20     // Number of objects per page
    var pageNumToLoad = 1           // Page number to download
    var currentPageNum = 0          // Current page
    var startPageNum = 1            // Start page number (for example, if the user clicked on the 2nd page, it will be 2. But if the user reached the 2nd page through "Show more", then startPageNum will remain 1)
    var loadedPagesNums = [Int]()   // Loaded pages (if loading was used)
    var keepOldObjects = false      // A flag that determines whether old objects should be kept after a new data load
    var reloadObjects = false       // Flag specifying whether to reload the feature page after a new data load
    
    
    // MARK: - Properties (Data)
    
    /* TODO: private(set) */var countAllObjects: Int = 0
    /* TODO: private(set) */var objects: [T]?
    /* TODO: private(set) */var pages: [Page<T>]?
    
    
    // MARK: - Private properties
    
    private var loadingMoreStateManager: LoadingMoreStateManager<LMP>
    private var loadingStateManager: LoadingStateManager<LP>
    
    
    // MARK: - Inits
    
    init(loadingPresenter: LP, loadingMorePresenter: LMP, loadingState: LoadingState = .stub, loadingMoreState: LoadingMoreState = .loadMoreResult) {
        self.loadingMoreStateManager = LoadingMoreStateManager<LMP>(presenter: loadingMorePresenter, state: loadingMoreState)
        self.loadingStateManager = LoadingStateManager<LP>(presenter: loadingPresenter, state: loadingState)
        super.init()
    }
    
    
    // MARK: - Override methods
    
    override func didUpdateResponse(_ response: DataResponse<W>?) {
        super.didUpdateResponse(response)
        
        // Loading did not even start (most likely due to incorrect input data).
        if request == nil {
            loadingStateManager.state.accept(.empty)
            return
        }
        
        // Loading has not completed yet, you need to show the stub.
        if isLoading {
            applyStubState()
            return
        }
        
        // Loading completed, results/errors can be displayed
        if let wrapperC = response?.result.value {
            
            if let objects = wrapperC.data, !objects.isEmpty {
                
                // Update the total number of objects if the page hasn't been reloaded because it may have changed since the last request
                if !reloadObjects {
                    countAllObjects = wrapperC.count ?? 0
                }
                
                // Save page
                if pages == nil {
                    pages = [Page<T>]()
                }
                
                if !keepOldObjects {
                    pages!.removeAll()
                }
                
                // If necessary and possible to get the actual index of the reloaded page in an array,
                if reloadObjects, let pageIndex = pages?.map({$0.num}).firstIndex(of: pageNumToLoad) {
                    
                    // then rewrite the page
                    pages![pageIndex] = Page(num: pageNumToLoad, objects: objects)
                } else {
                    
                    // otherwise add page
                    pages!.append(Page(num: pageNumToLoad, objects: objects))
                }
                
                // Save objects
                if keepOldObjects && self.objects != nil && !reloadObjects {
                    
                    self.objects!.append(contentsOf: objects)
                } else if reloadObjects {
                    
                    self.objects?.removeAll()
                    
                    // Collecting objects from pages to know for sure that the objects match
                    if let mappedPages = pages?.map({$0.objects}) {
                        
                        for mappedPage in mappedPages {
                            
                            self.objects?.append(contentsOf: mappedPage)
                        }
                    }
                } else {
                    
                    self.objects = objects
                }
                
                // Also do not forget to refresh the current page if the page has not been reloaded.
                if !reloadObjects {
                    currentPageNum = pageNumToLoad
                }
                
                // Clear the array of loaded pages if a new page was loaded
                if !keepOldObjects {
                    loadedPagesNums.removeAll()
                }
                
                // Adding a new page to the array of loaded pages if the page has not been reloaded
                if !reloadObjects {
                    loadedPagesNums.append(pageNumToLoad)
                }
                
                applyResultState()
            } else {
                
                applyEmptyState()
            }
            
        } else {
            
            applyErrorState()
        }
    }
    
    override func load() {
        
        // If at this stage the loader request (request) means there was some kind of error
        // (most likely, incorrect data at the input). But we still need to call super.load()
        // to update the tracked response property so that we can then somehow identify the error
        // in didUpdateResponse().
        if let request = self.request {
            
            // Checking parameters
            if countObjectsOnPage < 1 { countObjectsOnPage = 1 }
            if pageNumToLoad      < 1 { pageNumToLoad      = 1 }
            
            let parameters: Parameters = [
                key_count: countObjectsOnPage,
                key_start: pageNumToLoad,
                ]
            
            // Update the request parameters in the loader
            self.request = try! URLEncoding.default.encode(request, with: parameters)
            
            // print("urlRequest = \(request.urlRequest)")
            
            // Saving the last start page (if a reload is required later)
            if !keepOldObjects {
                
                startPageNum = pageNumToLoad
            }
        }
        
        super.load()
    }
    
    
    // MARK: - Methods
    
    func startListening() {
        
        loadingMoreStateManager.startListening(dataAdapter: self)
        loadingStateManager.startListening(dataAdapter: self)
    }
    
    func stopListening() {
        
        loadingMoreStateManager.stopListening()
        loadingStateManager.stopListening()
    }
    
    func currentPageIsFirstPage() -> Bool {
        return currentPageNum == 1
    }
    
    func currentPageIsLastPage() -> Bool {
        if let lastPageNum = getNumOfLastPage(),
            currentPageNum == lastPageNum {
            return true
        }
        return false
    }
    
    // Gets the total number of pages (both loaded and unloaded)
    func getCountAllPages() -> Int {
        
        if countAllObjects < 1 || countObjectsOnPage < 1 {
            return 0
        }
        
        return Int(ceilf(Float(countAllObjects) / Float(countObjectsOnPage)))
    }
    
    // Gets the last page number
    func getNumOfLastPage() -> Int? {
        let countAllPages = getCountAllPages() // Номер последней страницы совпадает с количеством страниц
        return countAllPages > 0 ? countAllPages : nil
    }
    
    // Checks if the next page can be loaded
    func isAvailableMore() -> Bool {
        return isAvailableNextPage()
    }

    // Checks if the next page is available
    func isAvailableNextPage() -> Bool {
        
        let countAllPages = getCountAllPages()
        return currentPageNum >= 0 && currentPageNum < countAllPages
    }
    
    // Checks if the specified page is available
    func isAvailablePage(num pageNum: Int) -> Bool {
        
        let countAllPages = getCountAllPages()
        return pageNum >= 1 && pageNum <= countAllPages
    }
    
    // Checks if the specified page is loaded
    func isLoadedPage(num pageNum: Int) -> Bool {
        return loadedPagesNums.contains(pageNum)
    }

    // Loads the first page
    func loadFirstPage() {
        keepOldObjects = false
        reloadObjects = false
        pageNumToLoad = 1
        load()
    }
    
    // Loads the next page
    func loadMore() {
        keepOldObjects = true
        reloadObjects = false
        pageNumToLoad = currentPageNum + 1
        load()
    }
    
    
    // MARK: - Private methods
    
    func applyEmptyState() {
        
        if keepOldObjects {
            loadingMoreStateManager.state.accept(.loadMoreEmpty)
        } else {
            loadingStateManager.state.accept(.empty)
        }
    }
    
    func applyErrorState() {
        
        if keepOldObjects {
            
            loadingMoreStateManager.state.accept(.loadMoreError)
        } else {
            
            loadingStateManager.state.accept(.error)
        }
    }
    
    func applyResultState() {
        
        if keepOldObjects {
            
            loadingMoreStateManager.state.accept(.loadMoreResult)
        } else {
            
            loadingMoreStateManager.state.accept(.loadMoreResult)
            loadingStateManager.state.accept(.result)
        }
    }
    
    func applyStubState() {
        
        if keepOldObjects {
            
            loadingMoreStateManager.state.accept(.loadMoreStub)
        } else {
            
            loadingStateManager.state.accept(.stub)
        }
    }
}

class Page<T> {
    
    var num: Int
    var objects: [T]
    
    init(num: Int, objects: [T]) {
        self.num = num
        self.objects = objects
    }
}
