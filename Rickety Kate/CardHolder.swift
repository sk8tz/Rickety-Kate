//
//  CardHolder.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 17/09/2015.
//  Copyright (c) 2015 Geoff Burns. All rights reserved.
//

import Foundation

public protocol CardHolder
{
    func cardsIn(suite:PlayingCard.Suite) -> [PlayingCard]
    var RicketyKate : PlayingCard? {get}
    var hand : [PlayingCard] { get }
}

public class CardHolderBase
{
    public var hand : [PlayingCard] = []
    public func cardsIn(suite:PlayingCard.Suite) -> [PlayingCard]
    {
        return hand.filter {$0.suite == suite}
    }
    public var RicketyKate : PlayingCard?
        {
            let RicketyKate = hand.filter { $0.isRicketyKate}
            
            return RicketyKate.first
    }
}

public class FakeCardHolder : CardHolderBase, CardHolder
{
    let cardSource = CardSource.sharedInstance

    //////////
    // internal functions
    //////////
    public func addCardsToHand(cardCodes:[String])
    {
        for code in cardCodes
        {
            let card : PlayingCard = cardSource[code]
            
            hand.append(card)
        }
    }
    
    public override init() {}
    
}