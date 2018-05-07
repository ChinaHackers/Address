//
//  AddressViewController.swift
//  Address
//
//  Created by Liu Chuan on 26/11/2016.
//  Copyright © 2016 LC. All rights reserved.
//



import UIKit

/// 重用标识符
private let cellID = "identify"

/// 显示类型
///
/// - Province: 省
/// - City: 市
/// - Area: 县
enum DisplayType {
    case Province
    case City
    case Area
}


class AddressViewController: UIViewController {
    
    // MARK: - 属性
    /// 表格
    fileprivate lazy var table: UITableView = { [unowned self] in
        let tab = UITableView(frame: self.view.bounds)
        tab.delegate = self
        tab.dataSource = self
        tab.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        return tab
    }()
    
    /// 记录显示类型
    fileprivate lazy var displayType = DisplayType.Province
  
    /// 省
    var provinces: [[String: Any]]!
    
    /// 市
    var citys: [[String: Any]]!

    /// 区
    var areas: [String] = []
    
    /// 记录选中类型
    var selectedProvince: String = ""
   
    /// 选中的市
    var selectedCity: String = ""
    
    /// 选中的区
    var selectedArea: String = ""
    
    /// 选中的index
    var selectedIndexPath: IndexPath!
    
    // MARK: - 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingData()
        loadingViews()
    }
    
    // MARK: - 方法
    /// 加载数据
    fileprivate func loadingData() {
        if displayType == .Province {
            //从文件读取地址字典
            // 获得plist的全路径
            guard let addressPath: String = Bundle.main.path(forResource: "address", ofType: "plist") else {return}
            // 加载plist
            guard let dict = NSDictionary(contentsOfFile: addressPath) else { return }
            provinces = dict.object(forKey: "address") as? [[String : Any]]
        }
    }
    
    /// 加载界面
    fileprivate func loadingViews() {
        view.addSubview(table)

        if displayType == .Province {   //选择省份页面时,显示取消按钮
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        }
        if displayType == .Area {       //选择区域页面时,显示确定按钮
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(confirm))
        }
    }
    
    /// 取消按钮点击事件
   @objc fileprivate func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 确定按钮点击事件
    @objc fileprivate func confirm() {
        
        let msg: String = "\(selectedProvince)-\(selectedCity)-\(selectedArea)"
        let alert = UIAlertController(title: "选择地址", message: msg, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension AddressViewController: UITableViewDataSource {
    
    /// 每个分区有多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch displayType {
        case .Province:
            return provinces.count
        case .City:
            return citys.count
        case .Area:
            return areas.count
        }
    }
    
    /// 每行显示的具体内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if displayType == .Area {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }else {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        
        switch displayType {
        case .Province:
            let provinceName = provinces[indexPath.row]["name"] as? String
            cell.textLabel?.text = provinceName
        case .City:
            let cityName = citys[indexPath.row]["name"] as? String
            cell.textLabel?.text = cityName
        case .Area:
            cell.textLabel?.text = areas[indexPath.row]
            cell.imageView?.image = UIImage(named: "unchecked")
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddressViewController: UITableViewDelegate {
 
    /// 选择行时调用
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch displayType {
        case .Province:
            let province = provinces[indexPath.row]
            let citys = province["sub"] as! [[String: Any]]
            selectedProvince = province["name"] as! String
            
            // 构建下一级视图控制器
            let cityVC = AddressViewController()
            cityVC.displayType = .City
            cityVC.citys = citys
            cityVC.selectedProvince = selectedProvince
            navigationController?.pushViewController(cityVC, animated: true)
        case .City:
            let city = citys[indexPath.row]
            let areas = city["sub"] as! [String]
            selectedCity = city["name"] as! String

            //构建下一级视图控制器
            let areaVC = AddressViewController()
            areaVC.displayType = .Area
            areaVC.areas = areas
            areaVC.selectedCity = selectedCity
            areaVC.selectedProvince = selectedProvince
            navigationController?.pushViewController(areaVC, animated: true)
        case .Area:
            if selectedIndexPath != nil {
                //取消上一次选定状态
                let oldCell: UITableViewCell = tableView.cellForRow(at: selectedIndexPath)!
                oldCell.imageView?.image = UIImage(named: "unchecked")
            }
            //勾选当前选定状态
            let newCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
            newCell.imageView?.image = UIImage(named: "checked")
            
            // 保存
            selectedArea = areas[indexPath.row]
            selectedIndexPath = indexPath
        }
    }
}
