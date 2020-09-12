//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import RxSwift
import XCTest

@testable import Radar_COVID

class SyncUseCaseTest: XCTestCase {
    
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
    }

    func testcheckNoNeedToSync() throws {
        let preferences = MockPreferences(lastSync: Date())
        let preferencesRepository = MockPreferencesRepository(preferences: preferences)
        let syncUseCase = SyncUseCase(preferencesRepository: preferencesRepository)
        
        let expectedResults = [EventTypes.onCompleted.rawValue]
        assert(syncUseCase: syncUseCase, using: expectedResults)
    }
    
    func testcheckForceSyncDueToLastSyncOlderThanInterval() throws {
        let lastSync = Date(timeIntervalSinceNow: -((12 * 60 * 60) + 1))
        let preferences = MockPreferences(lastSync: lastSync)
        let preferencesRepository = MockPreferencesRepository(preferences: preferences)
        let syncUseCase = SyncUseCase(preferencesRepository: preferencesRepository)
                
        let expectedResults = [EventTypes.onNext.rawValue, EventTypes.onCompleted.rawValue]
        assert(syncUseCase: syncUseCase, using: expectedResults)
    }
    
    func testcheckForceSyncDueToNoLastSync() throws {
        let preferences = MockPreferences(lastSync: nil)
        let preferencesRepository = MockPreferencesRepository(preferences: preferences)
        let syncUseCase = SyncUseCase(preferencesRepository: preferencesRepository)
                
        let expectedResults = [EventTypes.onNext.rawValue, EventTypes.onCompleted.rawValue]
        assert(syncUseCase: syncUseCase, using: expectedResults)
    }
    
    // MARK:- Private functions
    
    private func assert(syncUseCase: SyncUseCase, using expectedResults: [String]) {
        let expectation = XCTestExpectation()
        var actualResults = [String]()
        syncUseCase.syncIfNeeded().subscribe(onNext: { result in
            actualResults.append(EventTypes.onNext.rawValue)
        }, onError: { error in
            XCTFail("Error \(error)")
            actualResults.append(EventTypes.onError.rawValue)
        }, onCompleted: {
            actualResults.append(EventTypes.onCompleted.rawValue)
        }, onDisposed: {
            XCTAssertEqual(expectedResults, actualResults)
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 2.0)
    }

}
