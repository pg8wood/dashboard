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
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(10)
            
            Spacer()
            
            Text(name)
            
            Spacer()
            
            Image(uiImage: image) // TODO use status image
                .resizable()
                .scaledToFit()
                .frame(height: 50)
        }
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
