//
//  AddressViewController.swift
//  Address
//
//  Created by Liu Chuan on 26/11/2016.
//  Copyright © 2016 LC. All rights reserved.
//



import UIKit

//全局变量定义: 省\市\区
private let DisplayProvince = 0     // 省份
private let DisplayCity = 1         // 市
private let DisplayArea = 2         // 区县

private let cellID = "identify"  // 重用标识符

class AddressViewController: UIViewController {
    
    // MARK: - 属性
    var table: UITableView!
    var displayType: Int = 0        // 记录显示类型
    
    var provinces: [Any] = []
    var citys: [Any] = []
    var areas: [Any] = []
    
    
    var selectedProvince: String = ""       //选中的省
    var selectedCity: String = ""           //选中的市
    var selectedArea: String = ""           //选中的区
    var selectedIndexPath: IndexPath!       //选中的index
    
    // MARK: - 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()

        // 加载数据
        loadingData()
        
        // 加载视图
        loadingViews()
        
    }
    
    
    // MARK: - 加载数据
    fileprivate func loadingData() {
        if displayType == DisplayProvince {
        
        
            //从文件读取地址字典
            let addressPath: String = Bundle.main.path(forResource: "address", ofType: "plist")!
            let dict = NSDictionary(contentsOfFile: addressPath)
            provinces = dict?.object(forKey: "address") as! [Any]
        }
        
    }
    
    // MARK: - 加载界面
    fileprivate func loadingViews() {
        
        // 设置tableView属性
        table = UITableView(frame: self.view.bounds)
        table.delegate = self
        table.dataSource = self
       
        // 注册cell
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.addSubview(table)

        if displayType == DisplayProvince {   //选择省份页面时,显示取消按钮
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        }
        if displayType == DisplayArea {       //选择区域页面时,显示确定按钮
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(confirm))
        }
    }
    
    // MARK: - 取消按钮点击事件
   @objc fileprivate func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 确定按钮点击事件
    @objc fileprivate func confirm() {
        
        let msg: String = "\(selectedProvince)-\(selectedCity)-\(selectedArea)"
        let alert = UIAlertController(title: "选择地址", message: msg, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - 遵守 UITableViewDataSource 协议
extension AddressViewController: UITableViewDataSource {
    
    // MARK: 每个分区有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if displayType == DisplayProvince {     // 如果等于省份,显示省份的个数
            return provinces.count
        } else if displayType == DisplayCity {  // 如果等于市,显示市的个数
            return citys.count
        } else {                                // 否则,显示区的个数
            return areas.count
         }
    }
    
    // MARK: 每行显示的具体内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if displayType == DisplayArea {             // 如果是区县
            cell.accessoryType = UITableViewCellAccessoryType.none
        }else {
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        
        if displayType == DisplayProvince {         // 如果是省份
            
            let province: NSDictionary = provinces[indexPath.row] as! NSDictionary
            let provinceName = province.object(forKey: "name")
            cell.textLabel?.text = provinceName as! String?
            
        } else if displayType == DisplayCity{       // 如果是市
            

            //swift3.0 支持 用 [AnyHashable：Any] 代替 [NSObject：AnyObject] 或 NSDictionary 申明集合类型.
            
            //let city: [AnyHashable: Any] = citys[indexPath.row] as! [AnyHashable : Any]
            //let cityName: String = (city["name"] as? String)!
            //cell.textLabel?.text = cityName

            
            let city: NSDictionary = citys[indexPath.row] as! NSDictionary
            let cityName = city.object(forKey: "name")
            cell.textLabel?.text = cityName as? String
            

        } else {
            cell.textLabel?.text = areas[indexPath.row] as? String
            cell.imageView?.image = UIImage(named: "unchecked")
        }
        
        return cell
        
    }
    
}

// MARK: - 遵守 UITableViewDelegate 协议
extension AddressViewController: UITableViewDelegate {
    
    //MARK: 选择行时调用
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if displayType == DisplayProvince {
            
            let province: NSDictionary = provinces[indexPath.row] as! NSDictionary
            let citys = province.object(forKey: "sub")
            selectedProvince = province.object(forKey: "name") as! String

            // 构建下一级视图控制器
            let cityVC = AddressViewController()
            cityVC.displayType = DisplayCity      //显示模式为城市
            cityVC.citys = citys as! [Any]
            cityVC.selectedProvince = selectedProvince
            
            navigationController?.pushViewController(cityVC, animated: true)
            
        } else if displayType  == DisplayCity {
            
            let city: NSDictionary = citys[indexPath.row] as! NSDictionary
            let areas = city.object(forKey: "sub")
            selectedCity = city.object(forKey: "name") as! String
            
            //构建下一级视图控制器
            let areaVC = AddressViewController()
            areaVC.displayType = DisplayArea            // 显示模式为 区域
            areaVC.areas = areas as! [Any]
            areaVC.selectedCity = selectedCity
            areaVC.selectedProvince = selectedProvince
     
            navigationController?.pushViewController(areaVC, animated: true)
            
        } else {
            
            if selectedIndexPath != nil {
                //取消上一次选定状态
                let oldCell: UITableViewCell = tableView.cellForRow(at: selectedIndexPath)!
                oldCell.imageView?.image = UIImage(named: "unchecked")
            }
            
            //勾选当前选定状态
            let newCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
            newCell.imageView?.image = UIImage(named: "checked")
        
            // 保存
            selectedArea = areas[indexPath.row] as! String
            selectedIndexPath = indexPath
            
        }
        
    }
    
}
