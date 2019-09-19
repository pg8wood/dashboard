//
//  ServiceItem.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ServiceRow: View {
    var name: String
    var url: String
    var image: UIImage
    var statusImage: UIImage
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .padding(10)
                .frame(width: 80, height: 50)
            
            Spacer()
            
            Text(name)
            
            Spacer()
            
            Image(uiImage: statusImage)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 50)
        }
        .animation(.easeInOut)
        .frame(height: 80)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
    
}

#if DEBUG
//struct ServiceItem_Previews: PreviewProvider {
//    static var previews: some View {
//        let model = MockServiceModel(name: "Hi")
//        
//        return ServiceRow(model: model)
//    }
//}
#endif
