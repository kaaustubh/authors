    //
//  AuthorService.swift
//  Authors
//
//  Created by Kaustubh on 24/06/20.
//  Copyright © 2020 KaustubhtestApp. All rights reserved.
//

import Foundation

class AuthorService {
    
    private let client = NetworkEngine(baseUrl: "https://sym-json-server.herokuapp.com")
    
    @discardableResult
    func fetchAuthors(completion: @escaping ([Author]?, CustomError?) -> ()) -> URLSessionDataTask? {
        let params: JSON = [:]
        
        return client.load(path: "/authors", method: .get, params: params) { result, error in
            if (result != nil) {
                let authors = try! JSONDecoder().decode(Authors.self, from: result as! Data)
                if authors.count > 0{
                    completion(authors, nil)
                    LocalStorage().saveAuthors(authors: authors)
                }
                else {
                        completion(nil, CustomError(code: 405, type: "NoResult", message: "No results found"))
                }
            }
            else {
                let authors = LocalStorage().getAuthors()
                if authors.count > 0 {
                    completion(authors, nil)
                }
                else {
                    completion(nil, CustomError(code: 405, type: "NoResult", message: "No results found"))
                }
            }
        }
    }
    
    
    @discardableResult
    func fetchPostsFor(author id: String, completion: @escaping ([Post]?, CustomError?) -> ()) -> URLSessionDataTask? {
        let params: JSON = ["_authorId": id, "_sort": "date", "_order": "asc"]
        
        return client.load(path: "/posts", method: .get, params: params) { result, error in
            if (error != nil) {
                let posts = LocalStorage().getPostsOf(authorId: id)
                if posts.count > 0 {
                    completion(posts, nil)
                }
                else {
                    completion(nil, error)
                }
            }
            else if (result != nil) {
                let posts = try! JSONDecoder().decode(Posts.self, from: result as! Data)
                completion(posts, nil)
                LocalStorage().savePostsOf(authorId: id, posts: posts)
            }
            else {
                completion(nil, CustomError(code: 405, type: "NoResult", message: "No results found"))
            }
        }
    }
    
    @discardableResult
    func fetchCommentsFor(post id: String, completion: @escaping ([Comment]?, CustomError?) -> ()) -> URLSessionDataTask? {
        let params: JSON = [ "_sort": "date", "_order": "asc"]
        return client.load(path: "/posts/\(id)/comments", method: .get, params: params) { result, error in
            if (error != nil) {
                let comments = LocalStorage().getCommentsFor(postId: id)
                if comments.count > 0 {
                    completion(comments, nil)
                }
                else {
                    completion(nil, error)
                }
            }
            else if (result != nil) {
                let comments = try! JSONDecoder().decode(Comments.self, from: result as! Data)
                LocalStorage().saveCommentsFor(postId: id, comments: comments)
                completion(comments, nil)
            }
            else {
                completion(nil, CustomError(code: 405, type: "NoResult", message: "No results found"))
            }
        }
    }
}
