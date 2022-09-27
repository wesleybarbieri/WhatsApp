//
//  LoginViewController.swift
//  WhatsApp
//
//  Created by Wesley Camilo on 13/09/22.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
    @IBOutlet weak var campoEmail: UITextField!
    @IBOutlet weak var campoSenha: UITextField!
    var auth: Auth!
    var handler: AuthStateDidChangeListenerHandle!
    override func viewDidLoad() {
        super.viewDidLoad()

        auth = Auth.auth()
        //Adicionar o listener para autenticacao de  usuartio
        //nessa maneira o listener fica ativa para o app interiro
        self.handler = self.auth.addStateDidChangeListener { autenticacao, usuario in
            if usuario != nil {
                self.performSegue(withIdentifier: "logarUsuario", sender: nil)
                
            }else {
               print("Erro autenticacao")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        //para quando feixar a tela ele para o listener que esta no handler caso seja nescessario
       // auth.removeStateDidChangeListener(handler)
    }
    
    @IBAction func logar(_ sender: Any) {
        if let email = campoEmail.text{
            if let senha = campoSenha.text{
                auth.signIn(withEmail: email, password: senha) {(usuario, erro) in
                    if erro == nil {
                        if let usuarioLogado = usuario {
                            print("Sucesso ao logar o usuario \(String(describing: usuarioLogado.user.email)) ")
                            }
                    }else{
                        print("Erro ao autenticar o usuario!")
                    }
                }
            }else {
                print("Digite sua Senha")
            }
        }else {
            print("Digite seu E-mail")
        }
    }
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
