//
//  SubscriptionManager.swift
//  starship-tactics
//
//  Created by James Randall on 07/12/2024.
//

import Combine

nonisolated(unsafe) var cancellables : [AnySubscriptionManager] = []

protocol AnySubscriptionManager { }

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
        self.cancellable = binding.sink { [weak self] newValue in
            guard let self = self else { return }
            //print("PositionedView: \(newValue)")
            //let translatedValue = translation?(newValue) ?? newValue
            self.positionRef.value = newValue
            //print("Translated: \(translatedValue)")
            self.runtimeRef?.value?.requestRenderUpdate()
        }
        cancellables.append(self)
    }
}
