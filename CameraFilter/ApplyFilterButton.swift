//
//  ApplyFilterButton.swift
//  CameraFilter
//
//  Created by Gustavo Kumasawa on 16/05/22.
//

import UIKit

class ApplyFilterButton: UIButton {
    private lazy var label: UILabel = UILabel()
    private var cameraFilterHandler: CameraFilterHandler!
    var filter: CameraFilterHandler.Filters!
    var filterActive: Bool = false
    
    init(
        frame: CGRect = .zero,
        cameraFilterHandler: CameraFilterHandler,
        filter: CameraFilterHandler.Filters
    ) {
        super.init(frame: frame)
        
        self.cameraFilterHandler = cameraFilterHandler
        self.filter = filter
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.setTitle(filter.rawValue, for: .normal)
        self.setTitleColor(.blue, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 14)
        
        self.addTarget(self, action: #selector(handleButtonPress), for: .touchUpInside)
        self.setTitleColor(.blue, for: .normal)
    }
    
    @objc private func handleButtonPress() {
        if filterActive {
            removeFilter()
            return
        }
        
        applyFilter()
    }
    
    private func applyFilter() {
        cameraFilterHandler.filtersToApply.append(filter)
        
        filterActive = true
        self.setTitleColor(.green, for: .normal)
    }
    
    private func removeFilter() {
        guard let index = cameraFilterHandler.filtersToApply.firstIndex(
            where: { $0 == filter }
        ) else {
            return
        }

        cameraFilterHandler.filtersToApply.remove(at: index)
        
        filterActive = false
        self.setTitleColor(.blue, for: .normal)
    }
}
