import React from 'react';
import Button from '../components/Button';
import Input from '../components/Input';
import Table from '../components/Table';

const stores = [
  ['STR-001', 'Central Warehouse', 'Riyadh', 'Active'],
  ['STR-014', 'Spare Parts Hub', 'Jeddah', 'Active'],
  ['STR-021', 'Service Depot', 'Dammam', 'Under Review'],
];

export default function MasterDataStores() {
  return (
    <div className="content-card" style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16 }}>
        <div>
          <h2>Master Data · Stores</h2>
          <p style={{ marginTop: 8, color: 'var(--m365-muted)' }}>
            Manage store master records, locations, and operational status.
          </p>
        </div>
        <Button>New Store</Button>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
          gap: 16,
        }}
      >
        <div>
          <label style={{ fontSize: 12, color: 'var(--m365-muted)' }}>Store Name</label>
          <Input placeholder="Search by name" />
        </div>
        <div>
          <label style={{ fontSize: 12, color: 'var(--m365-muted)' }}>City</label>
          <Input placeholder="All cities" />
        </div>
        <div>
          <label style={{ fontSize: 12, color: 'var(--m365-muted)' }}>Status</label>
          <Input placeholder="Active" />
        </div>
        <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8 }}>
          <Button variant="secondary">Reset</Button>
          <Button>Apply Filters</Button>
        </div>
      </div>

      <Table
        headers={['Store ID', 'Store Name', 'City', 'Status']}
        rows={stores.map((store) => store)}
      />
    </div>
  );
}
