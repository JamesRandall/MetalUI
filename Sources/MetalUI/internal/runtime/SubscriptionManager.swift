//
//  SubscriptionManager.swift
//  starship-tactics
//
//  Created by James Randall on 07/12/2024.
//

import Combine

// TODO: this needs implementing properly

nonisolated(unsafe) var cancellables : [AnySubscriptionManager] = []

class AnySubscriptionManager { }

class SubscriptionManager<TValue> : AnySubscriptionManager {
    private var cancellable: AnyCancellable?
    private let positionRef: ValueRef<TValue>
    private let runtimeRef: RuntimeRef?

    @MainActor
    init(
        binding: Published<TValue>.Publisher,
        positionRef: ValueRef<TValue>,
        runtimeRef: RuntimeRef?
    ) {
        self.positionRef = positionRef
        self.runtimeRef = runtimeRef
        self.cancellable = binding.sink { [weak positionRef, weak runtimeRef] newValue in
            positionRef?.value = newValue
            runtimeRef?.value?.requestRenderUpdate()
        }
        super.init()
        cancellables.append(self)
    }
    
    deinit {
        self.cancellable?.cancel()
        if let index = cancellables.firstIndex(where: { $0 === self }) {
            cancellables.remove(at: index)
        }
    }
}
