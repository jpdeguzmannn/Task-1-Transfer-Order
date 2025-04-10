codeunit 50103 "TransferLinePriceCalcu"
{
    procedure GetTransferLineUnitPrice(TransferLine: Record "Transfer Line"): Decimal
    var
        Item: Record Item;
        PriceListLine: Record "Price List Line";
        UnitPrice: Decimal;
    begin
        // Initialize variables
        UnitPrice := 0;

        // First try to get the item to check if it exists
        if not Item.Get(TransferLine."Item No.") then
            exit(0); // Item doesn't exist, return 0

        // Try to get price from default sales price list
        if TryGetPriceFromDefaultSalesPriceList(TransferLine, PriceListLine) then
            UnitPrice := PriceListLine."Unit Price"
        else
            // Fall back to Item's Unit Price if no price found in price list
            UnitPrice := Item."Unit Price";

        exit(UnitPrice);
    end;

    procedure CalculateConfirmedAmount(TransferLine: Record "Transfer Line"): Decimal
    begin
        exit(TransferLine."Unit Price Excl./Incl. VAT" * TransferLine."Quantity Received");
    end;


    local procedure TryGetPriceFromDefaultSalesPriceList(TransferLine: Record "Transfer Line"; var PriceListLine: Record "Price List Line"): Boolean
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // Get the default sales price list code from setup
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Default Price List Code" = '' then
            exit(false);

        // Find the active price in the default price list
        PriceListLine.SetRange("Price List Code", SalesReceivablesSetup."Default Price List Code");
        PriceListLine.SetRange(Status, PriceListLine.Status::Active);
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", TransferLine."Item No.");

        // Check only if current date is within Starting and Ending date
        PriceListLine.SetFilter("Starting Date", '<=%1', Today());
        PriceListLine.SetFilter("Ending Date", '%1|>=%2', 0D, Today());

        PriceListLine.SetRange("Unit of Measure Code", TransferLine."Unit of Measure Code");

        if not PriceListLine.FindFirst() then begin
            // Try without Unit of Measure Code
            PriceListLine.SetRange("Unit of Measure Code", '');
            exit(PriceListLine.FindFirst());
        end;

        exit(true);
    end;

    procedure CalculateHeaderTotals(var TransferHeader: Record "Transfer Header"; OnlyNonPostedLines: Boolean)
    var
        TransferLine: Record "Transfer Line";
        TotalToDeliver: Decimal;
        TotalConfirmed: Decimal;
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");

        if OnlyNonPostedLines then
            TransferLine.SetRange("Quantity Shipped", 0);

        if TransferLine.FindSet() then
            repeat
                TotalToDeliver += TransferLine."Line Amount Excl./Incl. VAT";
                TotalConfirmed += TransferLine."Confirmed Line Amount Excl./Incl. VAT";
            until TransferLine.Next() = 0;

        TransferHeader."Total Amount to Deliver" := TotalToDeliver;
        TransferHeader."Total Amount Confirmed" := TotalConfirmed;
    end;

    procedure UpdateHeaderTotals(TransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.Get(TransferLine."Document No.") then begin
            CalculateHeaderTotals(TransferHeader, true); // Only calculate non-posted lines
            TransferHeader.Modify();
        end;
    end;
}