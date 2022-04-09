//
/*
* ****************************************************************
*
* 文件名称 : DynamicListCombineViewModel
* 作   者 : Created by 坤
* 创建时间 : 2022/4/8 20:26
* 文件描述 : 
* 注意事项 : 
* 版权声明 : 
* 修改历史 : 2022/4/8 初始版本
*
* ****************************************************************
*/

import Foundation

protocol DynamicListCombineViewModelInputs {
    
}

protocol DynamicListCombineViewModelOutputs {
    
}

protocol DynamicListCombineViewModelType {
    var input: DynamicListCombineViewModelInputs { get }
    var output: DynamicListCombineViewModelOutputs { get }
}

final class DynamicListCombineViewModel: DynamicListCombineViewModelType, DynamicListCombineViewModelInputs, DynamicListCombineViewModelOutputs {

    var input: DynamicListCombineViewModelInputs { self }
    var output: DynamicListCombineViewModelOutputs { self }

    init() {
        
    }

}
