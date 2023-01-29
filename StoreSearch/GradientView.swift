import UIKit

class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {   //  Обязательный метод
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {    //  В init() делаем фон прозрачным, а в draw() накладываем поверх фона градиент
        let traits = UITraitCollection.current  //  Получаем доступ к текущим характеристикам iOS, в зависимости от Светлой/Темной темы выбираем значение .light
        let color: CGFloat = traits.userInterfaceStyle == .light ? 0.314 : 1
        
        //  Создаём два массива с цветами и координатами, нужны для радиального градиента
        let components: [CGFloat] = [
            color, color, color, 0.2,
            color, color, color, 0.4,
            color, color, color, 0.6,
            color, color, color, 1]
        let locations: [CGFloat] = [0, 0.5, 0.75, 1]
        
        //  Экземпляр градиента
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(
            colorSpace: colorSpace,
            colorComponents: components,
            locations: locations,
            count: 4)
        
        // Описываем внешний вид градиента, где х у - центр
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        // Получаем контекст для будущей отрисовки
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(
            gradient!,
            startCenter: centerPoint,
            startRadius: 0,
            endCenter: centerPoint,
            endRadius: radius,
            options: .drawsAfterEndLocation)
    }
}
