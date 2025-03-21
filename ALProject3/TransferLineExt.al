tableextension 50100 "Transfer Line Extension" extends "Transfer Line"
{
    fields
    {
        // Unit Price Excl./Incl. VAT
        field(50100; "Unit Price Excl./Incl. VAT"; Decimal)
        {
            Caption = 'Unit Price Excl./Incl. VAT';
            Description = 'Shows the Unit Price from the Default Sales Price List or Item Card';
            Editable = false;
        }

        // Line Amount Excl./Incl. VAT
        field(50101; "Line Amount Excl./Incl. VAT"; Decimal)
        {
            Caption = 'Line Amount Excl./Incl. VAT';
            Description = 'Unit Price Excl./Incl. VAT multiplied by Quantity';
            Editable = false;
        }

        // Confirmed Line Amount Excl./Incl. VAT
        field(50102; "Confirmed Line Amount Excl./Incl. VAT"; Decimal)
        {
            Caption = 'Confirmed Line Amount Excl./Incl. VAT';
            Description = 'Unit Price Excl./Incl. VAT multiplied by Quantity Received';
            Editable = false;
        }

        // Total Amount to Deliver
        field(50103; "Total Amount to Deliver"; Decimal)
        {
            Caption = 'Total Amount to Deliver';
            Description = 'Sum of all Line Amount Excl./Incl. VAT in the Lines FastTab';
            Editable = false;
        }

        // Total Amount Confirmed
        field(50104; "Total Amount Confirmed"; Decimal)
        {
            Caption = 'Total Amount Confirmed';
            Description = 'Sum of all Confirmed Line Amount Excl./Incl. VAT in the Lines FastTab';
            Editable = false;
        }
    }

    // Trigger to update fields when Quantity or Quantity Received changes
    trigger OnAfterModify()
    begin
        UpdateUnitPrice();
        UpdateLineAmount();
        UpdateConfirmedLineAmount();
        UpdateTotals();
    end;

    // Trigger to update fields when a new line is inserted
    trigger OnAfterInsert()
    begin
        UpdateUnitPrice();
        UpdateLineAmount();
        UpdateConfirmedLineAmount();
        UpdateTotals();
    end;

    // Trigger to update totals when a line is deleted
    trigger OnAfterDelete()
    begin
        UpdateTotals();
    end;

    // Local procedure to update Unit Price
    local procedure UpdateUnitPrice()
    var
        TransferHeader: Record "Transfer Header";
    begin
        // Get the Transfer Header to access the Posting Date
        if TransferHeader.Get("Document No.") then
            "Unit Price Excl./Incl. VAT" := GetUnitPrice("Item No.", TransferHeader."Posting Date");
    end;

    // Local procedure to update Line Amount
    local procedure UpdateLineAmount()
    begin
        "Line Amount Excl./Incl. VAT" := "Unit Price Excl./Incl. VAT" * Quantity;
    end;

    // Local procedure to update Confirmed Line Amount
    local procedure UpdateConfirmedLineAmount()
    begin
        "Confirmed Line Amount Excl./Incl. VAT" := "Unit Price Excl./Incl. VAT" * "Quantity Received";
    end;

    // Local procedure to update Totals
    local procedure UpdateTotals()
    var
        TransferLine: Record "Transfer Line";
        TransferHeader: Record "Transfer Header";
        TotalAmountToDeliver: Decimal;
        TotalAmountConfirmed: Decimal;
    begin
        // Calculate the totals for all lines in the Transfer Order
        TransferLine.SetRange("Document No.", "Document No.");
        TransferLine.CalcSums("Line Amount Excl./Incl. VAT", "Confirmed Line Amount Excl./Incl. VAT");

        // Store the calculated sums in the variables
        TotalAmountToDeliver := TransferLine."Line Amount Excl./Incl. VAT";
        TotalAmountConfirmed := TransferLine."Confirmed Line Amount Excl./Incl. VAT";

        // Update the Total Amount to Deliver and Total Amount Confirmed in the Transfer Header
        if TransferHeader.Get("Document No.") then begin
            TransferHeader."Total Amount to Deliver" := TotalAmountToDeliver;
            TransferHeader."Total Amount Confirmed" := TotalAmountConfirmed;
            TransferHeader.Modify();
        end;

        // Update the Total Amount to Deliver and Total Amount Confirmed in the Transfer Line
        "Total Amount to Deliver" := TotalAmountToDeliver;
        "Total Amount Confirmed" := TotalAmountConfirmed;
    end;

    // Local procedure to fetch Unit Price
    local procedure GetUnitPrice(ItemNo: Code[20]; PostingDate: Date): Decimal
    var
        SalesPrice: Record "Sales Price";
        Item: Record Item;
    begin
        // Check Sales Price List
        SalesPrice.SetRange("Item No.", ItemNo);
        SalesPrice.SetRange("Starting Date", 0D, PostingDate);
        SalesPrice.SetRange("Ending Date", PostingDate, 99991231D);
        if SalesPrice.FindFirst() then
            exit(SalesPrice."Unit Price");

        // If not found, get Unit Price from Item Card
        if Item.Get(ItemNo) then
            exit(Item."Unit Price");

        // Default to 0 if no price is found
        exit(0);
    end;
}